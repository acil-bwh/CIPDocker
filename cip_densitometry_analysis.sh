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


$dock unu resample -k tent -s = = x${down} -i /tmp/${cid}.nrrd -c cell  -o /tmp/${cid}_resampled.nrrd 

$dock python /ChestImagingPlatform/cip_python/dcnn/projects/lung_segmenter/lung_segmenter_dcnn.py \
--i /tmp/${cid}_resampled.nrrd --t combined  --o /tmp/${cid}_partialLungLabelMap_resampled.nrrd


$dock unu resample -k cheap -s = = ${z_size} -i /tmp/${cid}_partialLungLabelMap_resampled.nrrd  -c cell -o /tmp/${cid}_partialLungLabelMap.nrrd
$dock unu save -f nrrd -e gzip -i /tmp/${cid}_partialLungLabelMap.nrrd -o /tmp/${cid}_partialLungLabelMap.nrrd

$dock cp /tmp/${cid}_partialLungLabelMap.nrrd /host/${cid}_partialLungLabelMap.nrrd


else
echo "Segmentation already computed."
$dock cp /host/${cid}_partialLungLabelMap.nrrd /tmp/${cid}_partialLungLabelMap.nrrd
fi

if [ ! -s ${path}/${cid}_localHistogramEmphysema.nrrd ] ;then

z_offset=$(echo "scale=0; 5/${spacing}" | bc )	
$dock ExtractChestLabelMap -i /tmp/${cid}_partialLungLabelMap.nrrd -r "WholeLung" -o /tmp/${cid}_wholeLungLabelMap.nrrd
$dock python /ChestImagingPlatform/cip_python/classification/local_histogram_emphysema.py \
-i /tmp/${cid}.nrrd -m /tmp/${cid}_wholeLungLabelMap.nrrd -o /tmp/${cid}_localHistogramEmphysema.nrrd -t 4 -z ${z_offset}

$dock cp /tmp/${cid}_localHistogramEmphysema.nrrd /host/${cid}_localHistogramEmphysema.nrrd

else
echo "Local histogram emphysema masks already computed."
$dock cp /host/${cid}_localHistogramEmphysema.nrrd /tmp/${cid}_localHistogramEmphysema.nrrd
fi

if [ ! -s ${path}/${cid}_parenchymaPhenotypes.csv ] ;then

regions=( WholeLung RightLung LeftLung )
types=( NormalParenchyma ParaseptalEmphysema PanlobularEmphysema MildCentrilobularEmphysema ModerateCentrilobularEmphysema SevereCentrilobularEmphysema )
pairs=""
regions_string=""
  for rr in ${regions[@]}; do
    for tt in ${types[@]}; do
      pairs=`echo "$pairs,$rr,$tt"`
    done
    regions_string=`echo "$regions_string,$rr"`
  done

pairs=`echo $pairs | cut -d , -f2-1000`
regions_string=`echo $regions_string | cut -d , -f2-1000`


$dock MergeChestLabelMaps -u -b /tmp/${cid}_partialLungLabelMap.nrrd --overlay /tmp/${cid}_localHistogramEmphysema.nrrd  -o /tmp/${cid}_labelmap.nrrd

$dock python /ChestImagingPlatform/cip_python/phenotypes/parenchyma_phenotypes.py --in_ct /tmp/${cid}.nrrd --in_lm /tmp/${cid}_labelmap.nrrd \
--out_csv /tmp/${cid}_parenchymaPhenotypes.csv --cid ${cid} -r ${regions_string} -p ${pairs}

$dock cp /tmp/${cid}_parenchymaPhenotypes.csv  /host/${cid}_parenchymaPhenotypes.csv 

else
echo "Densitometry already computed."
fi

docker stop ${cont}
docker rm ${cont}


fi
