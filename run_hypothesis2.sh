#!/bin/bash

# Hypothesis 2: Optimizing cleanup threshold (alpha_limit)

KALLISTO="./kallisto-master/build/src/kallisto"
INDEX="./data/gencode.v44.kidx"
READS1="./data/sim_reads_1.fastq.gz"
READS2="./data/sim_reads_2.fastq.gz"
OUTPUT_BASE="./output/hypothesis2"

mkdir -p ${OUTPUT_BASE}

# Define parameter combinations
declare -a runs=(
    "H2A 1e-12"
    "H2B 1e-11"
    "H2C 1e-10"
    "H2D 1e-9"
    "H2E 1e-8"
    "H2F 1e-7"
    "H2G 1e-6"
    "H2H 1e-5"
    "H2I 1e-4"
    "H2J 1e-3"
    "H2K 1e-2"
    "H2L 1e-1"
    "H2M 1"
)

# Fixed parameters
ALPHA_CHANGE="0.01"
ALPHA_CHANGE_LIMIT="0.01"
N_ITER="10000"
MIN_ROUNDS="50"

# Create CSV header
echo "run_name,alpha_limit,runtime_seconds,iterations" > ${OUTPUT_BASE}/run_metrics.csv

# Loop through all runs
for run_params in "${runs[@]}"; do
    read -r run_name alpha_limit <<< "$run_params"
    OUTPUT_DIR="${OUTPUT_BASE}/${run_name}"
    mkdir -p ${OUTPUT_DIR}
    
    echo "Running ${run_name} (alpha_limit=${alpha_limit})..."
    start_time=$(date +%s)
    
    ${KALLISTO} quant \
        -i ${INDEX} \
        -o ${OUTPUT_DIR} \
        -t 4 \
        --em-alpha-change=${ALPHA_CHANGE} \
        --em-alpha-change-limit=${ALPHA_CHANGE_LIMIT} \
        --em-alpha-limit=${alpha_limit} \
        --em-max-iter=${N_ITER} \
        --em-min-rounds=${MIN_ROUNDS} \
        ${READS1} ${READS2} \
        > ${OUTPUT_DIR}/kallisto.log 2>&1
    
    end_time=$(date +%s)
    runtime=$((end_time - start_time))
    
    # Extract iterations
    iterations=$(grep "ran for" ${OUTPUT_DIR}/kallisto.log | grep -oP '\d+(?= rounds)' | sed 's/^0*//' || echo "NA")
    
    # Append to CSV
    echo "${run_name},${alpha_limit},${runtime},${iterations}" >> ${OUTPUT_BASE}/run_metrics.csv
    
    echo "  Completed in ${runtime}s (${iterations} iterations)"
done
