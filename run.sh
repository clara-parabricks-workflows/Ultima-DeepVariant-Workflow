#!/bin/bash 

# TODO: BAM, REF, and ENGINE will need to be stored publicly and downloaded
# in the final version of this demo 

DATA_DIR="/mnt/1tb_drive/data"
REF_DIR="/home/gburnett/parabricks/parabricks_sample/Ref"

BAM="${DATA_DIR}/HG002_005401-UGAv3-1-CACATCCTGCATGTGAT_rsq_filtered.bam"
REF="${REF_DIR}/Homo_sapiens_assembly38.fasta"
ENGINE="${DATA_DIR}/trt_engine_b128_opt128.eng"

CONTAINER="nvcr.io/nv-parabricks-dev/clara-parabricks:4.1.2-1.ultimaoct"

# Run DeepVariant using Parabricks 

docker run \
    --gpus all \ 
    -v ${DATA_DIR}:${DATA_DIR} \ 
    -v ${REF_DIR}:${REF_DIR} \ 
    pbrun deepvariant \
    --ref ${REF} 
    --in-bam ${BAM} \
    --out-variants ${DATA_DIR}/out.vcf \
    --num-gpus 4 \
    --pb-model-file ${ENGINE} \
    --channel-hmer-deletion-quality \
    --channel-hmer-insertion-quality \
    --channel-non-hmer-insertion-quality \
    --aux-fields-to-keep tp,t0 \
    --skip-bq-channel \
    --min-base-quality 5 \
    --dbg-min-base-quality 0 \
    --vsc-min-fraction-indels 0.06 \
    --vsc-min-fraction-snps 0.12 \
    --ws-min-windows-distance 20 \
    --max-read-size-512 \
    --no-channel-insert-size \
    --disable-use-window-selector-model \
    --p-error 0.005 \
    --channel-ins-size \
    --max-ins-size 10 \
    --vsc-min-fraction-hmer-indels 0.12 \
    --consider-strand-bias \
    --vsc-turn-on-non-hmer-ins-proxy-support \
    --run-partition \
    --gpu-num-per-partition 1 \
    --num-cpu-threads-per-stream 4 \
    --num-streams-per-gpu 8

# Run quality metrics 