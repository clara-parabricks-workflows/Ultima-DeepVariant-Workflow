#!/bin/bash 

# TODO: BAM, REF, and ENGINE will need to be stored publicly and downloaded
# in the final version of this demo 

DATA_DIR="/data"
REF_DIR="/data/ultima-GIAB-Oct-2023/parabricks_sample/Ref"

INPUT="$1"
WGS_COVERAGE="$2"
REF="${REF_DIR}/Homo_sapiens_assembly38.fasta"

ENGINE="${DATA_DIR}/a10_ultima_model.eng"

CONTAINER="nvcr.io/nv-parabricks-dev/clara-parabricks:4.1.2-1.ultimaoct"


# Run quality metrics 
docker run --rm \
        -v ${DATA_DIR}:${DATA_DIR} \
        -v ${REF_DIR}:${REF_DIR} \
        us.gcr.io/broad-gotc-prod/picard-cloud:3.0.0 \
        java -jar /usr/picard/picard.jar \
        CollectQualityYieldMetrics \
        INPUT=${INPUT} \
        R=${REF} \
        OQ=true \
        FLOW_MODE=true \
        OUTPUT=CollectQualityYieldMetrics.txt

docker run --rm \
        -v ${DATA_DIR}:${DATA_DIR} \
        -v ${REF_DIR}:${REF_DIR} \
        us.gcr.io/broad-gotc-prod/picard-cloud:3.0.0 \
        java -jar /usr/picard/picard.jar \
        CollectWgsMetrics \
        INPUT=${INPUT} \
        VALIDATION_STRINGENCY=SILENT \
        REFERENCE_SEQUENCE=${REF} \
        INCLUDE_BQ_HISTOGRAM=true \
        INTERVALS=${WGS_COVERAGE} \
        OUTPUT=CollectWgsMetrics.txt \
        USE_FAST_ALGORITHM=false \
        COUNT_UNPAIRED=true \
        COVERAGE_CAP=12500 \
        READ_LENGTH=250
        
docker run --rm \
        -v ${DATA_DIR}:${DATA_DIR} \
        -v ${REF_DIR}:${REF_DIR} \
        us.gcr.io/broad-gotc-prod/picard-cloud:3.0.0 \
        java -jar /usr/picard/picard.jar \
        CollectRawWgsMetrics \
        INPUT=${INPUT} \
        VALIDATION_STRINGENCY=SILENT \
        REFERENCE_SEQUENCE=reference \
        INCLUDE_BQ_HISTOGRAM=true \
        INTERVALS=${WGS_COVERAGE} \
        OUTPUT=CollectRawWgsMetrics.txt \
        USE_FAST_ALGORITHM=false \
        COUNT_UNPAIRED=true \
        COVERAGE_CAP=12500 \
        READ_LENGTH=250

docker run --rm \
        -v ${DATA_DIR}:${DATA_DIR} \
        -v ${REF_DIR}:${REF_DIR} \
         us.gcr.io/broad-gotc-prod/picard-cloud:3.0.0 \
         java -jar /usr/picard/picard.jar \
         CollectMultipleMetrics \
         INPUT=${INPUT} \
         REFERENCE_SEQUENCE=${REF} \
         OUTPUT=output_prefix.bam \
         ASSUME_SORTED=true \
         PROGRAM="null" \
         PROGRAM="CollectAlignmentSummaryMetrics" \
         PROGRAM="CollectGcBiasMetrics" \
         PROGRAM="QualityScoreDistribution" \
         METRIC_ACCUMULATION_LEVEL="SAMPLE" \
         METRIC_ACCUMULATION_LEVEL="LIBRARY"
         
# Run DeepVariant using Parabricks 

docker run --rm \
    --gpus all \
    -v ${DATA_DIR}:${DATA_DIR} \
    -v ${REF_DIR}:${REF_DIR} \
    ${CONTAINER} \
    pbrun deepvariant \
    --ref ${REF} \
    --in-bam ${INPUT} \
    --out-variants ${DATA_DIR}/output.vcf \
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
