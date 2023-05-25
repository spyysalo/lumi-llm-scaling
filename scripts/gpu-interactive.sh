#!/bin/bash

srun \
    --account=project_462000273 \
    --partition=small-g \
    --ntasks=1 \
    --gres=gpu:mi250:1 \
    --time=1:00:00 \
    --mem=256G \
    --pty \
    bash
