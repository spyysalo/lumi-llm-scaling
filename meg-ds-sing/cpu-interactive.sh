#!/bin/bash

PROJECT="project_462000273"

CONTAINER="pytorch-lumi_sles-rocm-5.5.1-python-3.10-pytorch-v2.0.1-apex-torchvision-torchdata-torchtext-torchaudio.sif"

srun \
    --account="$PROJECT" \
    --partition=standard \
    --ntasks=1 \
    --cpus-per-task=128 \
    --time=1:00:00 \
    --mem=200G \
    --pty \
    singularity exec -B "/scratch/$PROJECT" "$CONTAINER" \
    bash
