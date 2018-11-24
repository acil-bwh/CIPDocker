#!/bin/bash

usage="$(basename "$0") [-h] [-i] [-m]-- pipeline to calculate local histograms for emphysma on a CT and extract phenotypes.

where:
    -h  show this help text
    -i  input CT in nrrd format
    -m  input lung mask"

if [ "$1" == "-h" ]; then
  echo "${usage}"
  exit 0
fi 

while getopts “:i:m:” opt; do
  case $opt in
    i) ct=$OPTARG ;;
    m) partial=$OPTARG ;;
  esac
done

#ct=$1
#partial=$2

cid=`echo ${ct} | cut -d. -f1`

ExtractChestLabelMap -i ${partial} -r "WholeLung" -o ${cid}_wholeLungLabelMap.nrrd

python /ChestImagingPlatform/cip_python/classification/local_histogram_emphysema.py -i ${cid}.nrrd -m ${cid}_wholeLungLabelMap.nrrd -o ${cid}_localHistogramEmphysema.nrrd


types=NormalParenchyma,ParaseptalEmphysema,PanlobularEmphysema,MildCentrilobularEmphysema,ModerateCentrilobularEmphysema,SevereCentrilobularEmphysema
python /ChestImagingPlatform/cip_python/phenotypes/parenchyma_phenotypes.py --in_ct ${cid}.nrrd --in_lm ${cid}_localHistogramEmphysema.nrrd \
--out_csv ${cid}_parenchymaPhenotypes.csv --cid ${cid} -t ${types}