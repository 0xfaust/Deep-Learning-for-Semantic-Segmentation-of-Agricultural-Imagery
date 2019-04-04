#!/bin/bash

set -e

DATASET_DIR=$1

cd ..
RESEARCH_DIR=$(pwd)
CAPSICUM_ANNUUM_DIR="$DATASET_DIR/capsicum_annuum"
INIT_DIR="$CAPSICUM_ANNUUM_DIR/init_models"
EXP_DIR="$CAPSICUM_ANNUUM_DIR/exp"
EXP_ID="$EXP_DIR/style"
TRAIN_LOGDIR="$EXP_ID/train"
EVAL_LOGDIR="$EXP_ID/eval"
VIS_LOGDIR="$EXP_ID/vis"
EXPORT_DIR="$EXP_ID/export"
TF_RECORD_DIR="$CAPSICUM_ANNUUM_DIR/tfrecord"

# Update PYTHONPATH.
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Run model_test first to make sure the PYTHONPATH is correctly set.
python deeplab/model_test.py -v

# Train 30000 iterations.
NUM_ITERATIONS=30000
python deeplab/train.py \
  --logtostderr \
  --train_split="train" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --train_crop_size=513 \
  --train_crop_size=513 \
  --train_batch_size=10 \
  --num-classes 9 \
  --training_number_of_steps="${NUM_ITERATIONS}" \
  --fine_tune_batch_norm=false \
  --dataset="capsicum_annuum_style" \
  --train_logdir="${TRAIN_LOGDIR}" \
  --dataset_dir="${TF_RECORD_DIR}"

# Export the trained checkpoint.
CKPT_PATH="${TRAIN_LOGDIR}/model.ckpt-${NUM_ITERATIONS}"
EXPORT_PATH="${EXPORT_DIR}/frozen_inference_graph.pb"

python deeplab/export_model.py \
  --logtostderr \
  --checkpoint_path="${CKPT_PATH}" \
  --export_path="${EXPORT_PATH}" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --num_classes=9 \
  --crop_size=513 \
  --crop_size=513 \
  --inference_scales=1.0
