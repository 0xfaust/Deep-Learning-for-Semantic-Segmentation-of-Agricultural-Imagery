#!/bin/bash

set -e

DATASET_DIR=$1

cd ..
RESEARCH_DIR=$(pwd)
CAPSICUM_ANNUUM_DIR="$DATASET_DIR/capsicum_annuum"
INIT_DIR="$CAPSICUM_ANNUUM_DIR/init_models"
EXP_DIR="$CAPSICUM_ANNUUM_DIR/exp"
EXP_ID="$EXP_DIR/a"
TRAIN_LOGDIR="$EXP_ID/train"
EVAL_LOGDIR="$EXP_ID/eval"
VIS_LOGDIR="$EXP_ID/vis"
EXPORT_DIR="$EXP_ID/export"
TF_RECORD_DIR="$CAPSICUM_ANNUUM_DIR/tfrecord"

# Update PYTHONPATH.
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Run evaluation.
python deeplab/eval.py \
  --logtostderr \
  --eval_split="trainval" \
  --model_variant="xception_65" \
  --atrous_rates=6 \
  --atrous_rates=12 \
  --atrous_rates=18 \
  --output_stride=16 \
  --decoder_output_stride=4 \
  --eval_crop_size=600 \
  --eval_crop_size=800 \
  --dataset="capsicum_annuum_a" \
  --checkpoint_dir="${TRAIN_LOGDIR}" \
  --eval_logdir="${EVAL_LOGDIR}" \
  --dataset_dir="${TF_RECORD_DIR}" \
  --max_number_of_evaluations=1
