#!/bin/bash

srun \
    --account=project_462000273 \
    --partition=standard \
    --ntasks=1 \
    --cpus-per-task=128 \
    --time=24:00:00 \
    --mem=0 \
    --pty \
    bash
