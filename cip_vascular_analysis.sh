#!/bin/bash

cid=$1
path=$2

if [ ! -s ${path}/${cid}.nrrd ] && [ ! -d ${path}/${cid} ]; then

	echo "${cid} is not a dicom directory or a .nrrd volume at the working path"

else

cont=`docker run -ti -v ${path}:/host -d acilbwh/chestimagingplatform`
export dock="docker exec -ti ${cont} "

if [ ! -s ${path}/${cid}.nrrd ] ;then
$dock ConvertDicom --dir ${cid} -o ${cid}.nrrd
else
echo "${cid}.nrrd exists."
fi

$dock cp /host/${cid}.nrrd /tmp/${cid}.nrrd

z_size=`$dock unu head ${cid}.nrrd | grep sizes | cut -d" " -f4`
spacing=`$dock unu head ${cid}.nrrd | grep directions | cut -d, -f7 | cut -d\) -f1`
down=`awk "BEGIN {print ${spacing}/2}"`
up=`awk "BEGIN {print 2/${spacing}}"`

if [ ! -s ${path}/${cid}_partialLungLabelMap.nrrd ] ;then

$dock unu resample -k tent -s = = x${down} -i /tmp/${cid}.nrrd -c cell -o /tmp/${cid}_resampled.nrrd

$dock python /ChestImagingPlatform/cip_python/dcnn/projects/lung_segmenter/lung_segmenter_dcnn.py \
--i /tmp/${cid}_resampled.nrrd --t combined  --o /tmp/${cid}_partialLungLabelMap_resampled.nrrd

$dock unu resample -k cheap -s = = ${z_size} -i /tmp/${cid}_partialLungLabelMap_resampled.nrrd  -c cell -o /tmp/${cid}_partialLungLabelMap.nrrd
$dock unu save -f nrrd -e gzip -i /tmp/${cid}_partialLungLabelMap.nrrd -o /tmp/${cid}_partialLungLabelMap.nrrd

$dock cp /tmp/${cid}_partialLungLabelMap.nrrd /host/${cid}_partialLungLabelMap.nrrd

else
echo "Segmentation already computed."
$dock cp /host/${cid}_partialLungLabelMap.nrrd /tmp/${cid}_partialLungLabelMap.nrrd
fi


if [ ! -s ${path}/${cid}_wholeLungVesselParticles.vtk ]; then

$dock python /ChestImagingPlatform/Scripts/cip_compute_vessel_particles.py --tmpDir /tmp  -i /tmp/${cid}.nrrd -l /tmp/${cid}_partialLungLabelMap.nrrd -r RightLung --init Frangi \
-o /tmp/${cid} --liveTh -120 --seedTh -80 -s 0.625 --cleanCache
$dock python /ChestImagingPlatform/Scripts/cip_compute_vessel_particles.py --tmpDir /tmp  -i /tmp/${cid}.nrrd -l /tmp/${cid}_partialLungLabelMap.nrrd -r LeftLung --init Frangi \
-o /tmp/${cid} --liveTh -120 --seedTh -80 -s 0.625 --cleanCache

$dock MergeParticleDataSets -i /tmp/${cid}_rightLungVesselParticles.vtk -i /tmp/${cid}_leftLungVesselParticles.vtk --out /tmp/${cid}_wholeLungVesselParticles.vtk

$dock cp /tmp/${cid}_wholeLungVesselParticles.vtk /host/${cid}_wholeLungVesselParticles.vtk

else 

echo "Vessel particles already computed."
$dock cp /host/${cid}_wholeLungVesselParticles.vtk /tmp/${cid}_wholeLungVesselParticles.vtk
fi

if [ ! -s ${path}/${cid}_vascularPhenotypes.csv ]; then

pairs="WholeLung,Vessel,RightLung,Vessel,LeftLung,Vessel"
$dock LabelParticlesByChestRegionChestType --ilm /tmp/${cid}_partialLungLabelMap.nrrd  --ip /tmp/${cid}_wholeLungVesselParticles.vtk --op /tmp/${cid}_vesselPartial.vtk
$dock python /ChestImagingPlatform/cip_python/phenotypes/vasculature_phenotypes.py -i /tmp/${cid}_vesselPartial.vtk --cid ${cid} -p ${pairs}  --out_csv /tmp/${cid}_vascularPhenotypes.csv

$dock cp /tmp/${cid}_vascularPhenotypes.csv /host/${cid}_vascularPhenotypes.csv

else 

echo "Vascular phenotypes already computed."

fi


docker stop ${cont}
docker rm ${cont}

fi
