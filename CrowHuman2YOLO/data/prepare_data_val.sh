#!/bin/bash

set -e

# check argument
if [[ -z $1 || ! $1 =~ [[:digit:]]x[[:digit:]] ]]; then
  echo "ERROR: This script requires 1 argument, \"input dimension\" of the YOLO model."
  echo "The input dimension should be {width}x{height} such as 608x608 or 416x256.".
  exit 1
fi

if which python3 > /dev/null; then
  PYTHON=python3
else
  PYTHON=python
fi


pushd $(dirname $0)/raw > /dev/null

get_file()
{
  # do download only if the file does not exist
  if [[ -f $2 ]];  then
    echo Skipping $2
  else
    echo Downloading $2...
    python3 -m gdown.cli $1
  fi
}

echo "** Download dataset files"


# unzip image files (ignore CrowdHuman_test.zip for now)
echo "** Unzip dataset files"
for f in CrowdHuman_val.zip ; do
  unzip -n ${f}
done

echo "** Create the crowdhuman-$1/ subdirectory"

mkdir ../crowdhuman-$1/val_set/ #创建训练集
mkdir ../crowdhuman-$1/val_set/images/ #创建训练集的图像集
mkdir ../crowdhuman-$1/val_set/labels/ #创建训练集的标签

ln Images/*.jpg ../crowdhuman-$1/val_set/images/ #把图片迁移到图像集


echo "** Generate yolo txt files"
cd ..
${PYTHON} gen_txts_val.py $1

popd > /dev/null

echo "** Done."
