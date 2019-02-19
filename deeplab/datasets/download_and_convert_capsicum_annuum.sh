#!/bin/bash

set -e

EXP=$1
DATASET_DIR=$2

CURRENT_DIR=$(pwd)

# empirical data
EMPIRICAL_BASE_URL='https://data.4tu.nl/bulk/uuid_884958f5-b868-46e1-b3d8-a0b5d91b02c0'
EMPIRICAL_FILENAME_DATA='empirical_image_color.zip'
EMPIRICAL_FILENAME_LABELS='empirical_label_class_grayscale.zip'

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

if [[ $EXP == "A" ]]; then
  IMAGE_DIR="$CAPSICUM_ANNUUM_DIR/synthetic_image_color"
  GROUND_TRUTH_DIR="$CAPSICUM_ANNUUM_DIR/synthetic_label_class_grayscale/synthetic_label_class_all_grayscale"
  BASE_URL=$SYNTHETIC_BASE_URL
  FILENAME_DATA=$SYNTHETIC_FILENAME_DATA
  FILENAME_LABELS=$SYNTHETIC_FILENAME_LABELS
  EXP_ID="$EXP_DIR/a"
elif [[ $EXP == "B" ]]; then
  echo "Experiment B and E are not implemented yet."
  exit 1
elif [[ $EXP == "C" ]]; then
  IMAGE_DIR="$CAPSICUM_ANNUUM_DIR/empirical_image_color"
  GROUND_TRUTH_DIR="$CAPSICUM_ANNUUM_DIR/empirical_label_class_grayscale/empirical_label_class_all_grayscale"
  BASE_URL=$EMPIRICAL_BASE_URL
  FILENAME_DATA=$EMPIRICAL_FILENAME_DATA
  FILENAME_LABELS=$EMPIRICAL_FILENAME_LABELS
  EXP_ID="$EXP_DIR/c"
elif [[ $EXP == "D" ]]; then
  IMAGE_DIR="$CAPSICUM_ANNUUM_DIR/empirical_image_color"
  GROUND_TRUTH_DIR="$CAPSICUM_ANNUUM_DIR/empirical_label_class_grayscale/empirical_label_class_all_grayscale"
  BASE_URL=$EMPIRICAL_BASE_URL
  FILENAME_DATA=$EMPIRICAL_FILENAME_DATA
  FILENAME_LABELS=$EMPIRICAL_FILENAME_LABELS
  EXP_ID="$EXP_DIR/d"
elif [[ $EXP == "E" ]]; then
  echo "Experiment B and E are not implemented yet."
  exit 1
fi

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
download "${BASE_URL}" "${FILENAME_DATA}"
download "${BASE_URL}" "${FILENAME_LABELS}"

# Helper function to unpack dataset.
uncompress() {
  local BASE_URL=${1}
  local FILENAME=${2}

  echo "Uncompressing ${FILENAME}"
  unzip "${FILENAME}"
}

# Uncompress the images.
uncompress "${BASE_URL}" "${FILENAME_DATA}"
uncompress "${BASE_URL}" "${FILENAME_LABELS}"

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
rename 's/label_class_all_grayscale/image_color/' *.png

cd "${IMAGE_DIR}"

if [[ $EXP == "A" ]]; then
  ls -v | head -8750 | cut -d '.' -f 1 > "${LIST_DIR}/train.txt"
  ls -v | tail -49 | cut -d '.' -f 1 > "${LIST_DIR}/val.txt"
  cat "${LIST_DIR}/train.txt" "${LIST_DIR}/val.txt" > "${LIST_DIR}/trainval.txt"
elif [[ $EXP == "B" ]]; then
  echo "Experiment B and E are not implemented yet."
  exit 1
elif [[ $EXP == "C" ]]; then
  ls -v | head -30 | cut -d '.' -f 1 > "${LIST_DIR}/train.txt"
  ls -v | tail -9 | cut -d '.' -f 1 > "${LIST_DIR}/val.txt"
  cat "${LIST_DIR}/train.txt" "${LIST_DIR}/val.txt" > "${LIST_DIR}/trainval.txt"
elif [[ $EXP == "D" ]]; then
  ls -v | head -30 | cut -d '.' -f 1 > "${LIST_DIR}/train.txt"
  ls -v | tail -9 | cut -d '.' -f 1 > "${LIST_DIR}/val.txt"
  cat "${LIST_DIR}/train.txt" "${LIST_DIR}/val.txt" > "${LIST_DIR}/trainval.txt"
elif [[ $EXP == "E" ]]; then
  echo "Experiment B and E are not implemented yet."
  exit 1
fi

echo "Converting Capsicum Annuum dataset..."
cd "$CURRENT_DIR"
python ./build_capsicum_annuum_data.py \
  --image_folder="${IMAGE_DIR}" \
  --semantic_segmentation_folder="${ANNOTATED_DIR}" \
  --list_folder="${LIST_DIR}" \
  --image_format="png" \
--output_dir="${TF_RECORD_DIR}"
