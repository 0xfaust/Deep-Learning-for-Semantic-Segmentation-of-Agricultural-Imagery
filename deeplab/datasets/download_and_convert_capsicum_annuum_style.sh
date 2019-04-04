#!/bin/bash

set -e

EXP=$1
DATASET_DIR=$2

CURRENT_DIR=$(pwd)

# synthetic data
SYNTHETIC_BASE_URL='https://data.4tu.nl/bulk/uuid_884958f5-b868-46e1-b3d8-a0b5d91b02c0'
SYNTHETIC_FILENAME_DATA='synthetic_image_color.zip'
SYNTHETIC_FILENAME_LABELS='synthetic_label_class_grayscale.zip'

# setup directories
CAPSICUM_ANNUUM_DIR="$DATASET_DIR/capsicum_annuum"
LIST_DIR="$CAPSICUM_ANNUUM_DIR/image_sets"
ANNOTATED_DIR="$CAPSICUM_ANNUUM_DIR/segmentation_class"
INIT_DIR="$CAPSICUM_ANNUUM_DIR/init_models"
EXP_DIR="$CAPSICUM_ANNUUM_DIR/exp"


IMAGE_DIR="$CAPSICUM_ANNUUM_DIR/stylised_images"
GROUND_TRUTH_DIR="$CAPSICUM_ANNUUM_DIR/synthetic_label_class_grayscale/synthetic_label_class_all_grayscale"
BASE_URL=$SYNTHETIC_BASE_URL
FILENAME_DATA=$SYNTHETIC_FILENAME_DATA
FILENAME_LABELS=$SYNTHETIC_FILENAME_LABELS
EXP_ID="$EXP_DIR/style"

TRAIN_LOGDIR="$EXP_ID/train"
EVAL_LOGDIR="$EXP_ID/eval"
VIS_LOGDIR="$EXP_ID/vis"
EXPORT_DIR="$EXP_ID/export"
TF_RECORD_DIR="$CAPSICUM_ANNUUM_DIR/tfrecord"

mkdir -p "${CAPSICUM_ANNUUM_DIR}"
mkdir -p "${LIST_DIR}"
mkdir -p "${ANNOTATED_DIR}"
mkdir -p "${INIT_DIR}"
mkdir -p "${TRAIN_LOGDIR}"
mkdir -p "${EVAL_LOGDIR}"
mkdir -p "${VIS_LOGDIR}"
mkdir -p "${EXPORT_DIR}"
mkdir -p "${TF_RECORD_DIR}"

cd "${CAPSICUM_ANNUUM_DIR}"

# Helper function to download dataset.
download(){
  local BASE_URL=${1}
  local FILENAME=${2}

  if [[ ! -f "${FILENAME}" ]]; then
    echo "Downloading ${FILENAME} to ${CAPSICUM_ANNUUM_DIR}"
    wget -q -nd -c  "${BASE_URL}/${FILENAME}"
  fi
}

# Download the images.
download "${SYNTHETIC_BASE_URL}" "${SYNTHETIC_FILENAME_LABELS}"

echo "Downloading Stylised Images"
wget -q -nd -c "https://storage.googleapis.com/drive-bulk-export-anonymous/20190404T182734Z/4133399871716478688/efdafad5-e12f-4f01-b0eb-4437a5586698/1/1072d4b9-c297-4862-8a72-40b38b49350b?authuser"

# Helper function to unpack dataset.
uncompress() {
  local BASE_URL=${1}
  local FILENAME=${2}

  echo "Uncompressing ${FILENAME}"
  unzip "${FILENAME}"
}

# Uncompress the images.
uncompress "${SYNTHETIC_BASE_URL}" "${SYNTHETIC_FILENAME_LABELS}"
mv stylised_images-20190404T182734Z-001.zip stylised_images.zip
unzip "stylised_images.zip"

echo "Removing the color map in ground truth annotations..."
echo "Ground truth directory: $GROUND_TRUTH_DIR"

cd "$CURRENT_DIR"

python ./remove_gt_colormap.py \
  --original_gt_folder="$GROUND_TRUTH_DIR" \
--output_dir="$ANNOTATED_DIR/raw"

cd "${ANNOTATED_DIR}/raw"
echo "${ANNOTATED_DIR}"
cp *.png ../
cd "${ANNOTATED_DIR}"
rename 's/label_class_all_grayscale/stylised/' *.png

cd "${IMAGE_DIR}"

ls -v | cut -d '.' -f 1 > "${LIST_DIR}/train.txt"
touch "${LIST_DIR}/val.txt"
cat "${LIST_DIR}/train.txt" "${LIST_DIR}/val.txt" > "${LIST_DIR}/trainval.txt"

echo "Converting Stylised dataset..."
cd "$CURRENT_DIR"
python ./build_capsicum_annuum_data.py \
  --image_folder="${IMAGE_DIR}" \
  --semantic_segmentation_folder="${ANNOTATED_DIR}" \
  --list_folder="${LIST_DIR}" \
  --image_format="png" \
--output_dir="${TF_RECORD_DIR}"
