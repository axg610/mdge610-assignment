#!/bin/bash

# Hypothesis 1: Testing alpha_change and alpha_change_limit

# Configuration
KALLISTO="./kallisto-master/build/src/kallisto"
INDEX="./data/gencode.v44.kidx"
READS1="./data/sim_reads_1.fastq.gz"
READS2="./data/sim_reads_2.fastq.gz"
OUTPUT_BASE="./output/hypothesis1"

# Create output directory
mkdir -p ${OUTPUT_BASE}

# Define parameter combinations
declare -a runs=(
    "H1A 0.1 0.1"
    "H1B 0.01 0.1"
    "H1C 0.001 0.1"
    "H1D 0.0001 0.1"
    "H1E 0.1 0.01"
    "H1F 0.01 0.01"
    "H1G 0.001 0.01"
    "H1H 0.0001 0.01"
    "H1I 0.1 0.001"
    "H1J 0.01 0.001"
    "H1K 0.001 0.001"
    "H1L 0.0001 0.001"
    "H1M 0.1 0.0001"
    "H1N 0.01 0.0001"
    "H1O 0.001 0.0001"
    "H1P 0.0001 0.0001"
)

# Create CSV header
echo "run_name,alpha_change,alpha_change_limit,runtime_seconds,iterations" > ${OUTPUT_BASE}/run_metrics.csv

# Loop through all runs
for run_params in "${runs[@]}"; do
    read -r run_name alpha_change alpha_change_limit <<< "$run_params"
    OUTPUT_DIR="${OUTPUT_BASE}/${run_name}"
    mkdir -p ${OUTPUT_DIR}
    
    echo "Running ${run_name}..."
    start_time=$(date +%s)
    
    ${KALLISTO} quant \
        -i ${INDEX} \
        -o ${OUTPUT_DIR} \
        -t 4 \
        --em-alpha-change=${alpha_change} \
        --em-alpha-change-limit=${alpha_change_limit} \
        --em-alpha-limit=1e-7 \
        --em-max-iter=10000 \
        --em-min-rounds=50 \
        ${READS1} ${READS2} \
        > ${OUTPUT_DIR}/kallisto.log 2>&1
    
    end_time=$(date +%s)
    runtime=$((end_time - start_time))
    
    # Extract iterations
    iterations=$(grep "ran for" ${OUTPUT_DIR}/kallisto.log | grep -oP '\d+(?= rounds)' || echo "NA")
    
    # Append to CSV
    echo "${run_name},${alpha_change},${alpha_change_limit},${runtime},${iterations}" >> ${OUTPUT_BASE}/run_metrics.csv
    
    echo "  Completed in ${runtime}s (${iterations} iterations)"
done
