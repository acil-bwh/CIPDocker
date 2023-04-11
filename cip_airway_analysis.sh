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


if [ ! -s ${path}/${cid}_wholeLungAirwayParticles.vtk ]; then

$dock python /ChestImagingPlatform/Scripts/cip_compute_airway_particles.py --tmpDir /tmp  -i /tmp/${cid}.nrrd -l /tmp/${cid}_partialLungLabelMap.nrrd -r RightLung --init Frangi \
-o /tmp/${cid} --liveTh 60 --seedTh 50 --cleanCache 
$dock python /ChestImagingPlatform/Scripts/cip_compute_airway_particles.py --tmpDir /tmp  -i /tmp/${cid}.nrrd -l /tmp/${cid}_partialLungLabelMap.nrrd -r LeftLung --init Frangi \
-o /tmp/${cid} --liveTh 60 --seedTh 50 --cleanCache 

$dock FilterAirwayParticleData -s 30 -r 0.8 -a 80 -i /tmp/${cid}_rightlungAirwayParticles.vtk -o /tmp/${cid}_rightlungAirwayParticles.vtk
$dock FilterAirwayParticleData -s 30 -r 0.8 -a 80 -i /tmp/${cid}_leftlungAirwayParticles.vtk -o /tmp/${cid}_leftlungAirwayParticles.vtk

$dock MergeParticleDataSets -i /tmp/${cid}_rightlungAirwayParticles.vtk -i /tmp/${cid}_leftlungAirwayParticles.vtk --out /tmp/${cid}_wholelungAirwayParticles.vtk

$dock cp /tmp/${cid}_wholelungAirwayParticles.vtk /host/${cid}_wholeLungAirwayParticles.vtk

else 

echo "Airway particles already computed."
$dock cp /host/${cid}_wholeLungAirwayParticles.vtk /tmp/${cid}_wholelungAirwayParticles.vtk
fi

if [ ! -s ${path}/${cid}_airwayPhenotypes.csv ]; then

pairs="WholeLung,Airway,LeftLung,Airway,RightLung,Airway"

$dock ComputeAirwayWallFromParticles --ict /tmp/${cid}.nrrd --ip /tmp/${cid}_wholelungAirwayParticles.vtk -m ZC -o /tmp/${cid}_airwayWall.vtk -n 15
$dock LabelParticlesByChestRegionChestType --ilm /tmp/${cid}_partialLungLabelMap.nrrd  --ip /tmp/${cid}_airwayWall.vtk --op /tmp/${cid}_particlesPartial.vtk
$dock python /ChestImagingPlatform/cip_python/phenotypes/airway_phenotypes.py --in_pd /tmp/${cid}_particlesPartial.vtk --cid ${cid} -p ${pairs} --out_csv /tmp/${cid}_airwayPhenotypes.csv

$dock cp /tmp/${cid}_airwayPhenotypes.csv /host/${cid}_airwayPhenotypes.csv

else 

echo "Airway phenotypes already computed."

fi


docker stop ${cont}
docker rm ${cont}

fi
