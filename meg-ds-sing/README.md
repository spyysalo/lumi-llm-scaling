# Megatron-DeepSpeed on LUMI with singularity container

This directory contains scripts and documentation related to running
[Megatron-DeepSpeed](https://github.com/microsoft/Megatron-DeepSpeed)
on LUMI.

## Quickstart

First create a new directory for your work (see top-level `README`) and
then run the following in that directory:

### Clone this repository

```
git clone https://github.com/spyysalo/lumi-llm-scaling.git
```

Work in this subdirectory

```
cd lumi-llm-scaling/meg-ds-sing
```

### Setup

Pull singularity container, using in-memory filsystem on `/tmp`. This
takes about 5 minutes.

```
mkdir /tmp/$USER
export SINGULARITY_TMPDIR=/tmp/$USER
export SINGULARITY_CACHEDIR=/tmp/$USER
singularity pull docker://sfantao/pytorch-lumi:sles-rocm-5.5.1-python-3.10-pytorch-v2.0.1-apex-torchvision-torchdata-torchtext-torchaudio
```

Install python packages to userspace

```
./cpu-interactive.sh

source /opt/miniconda3/bin/activate pytorch

python -m pip install --upgrade datasets evaluate accelerate scikit-learn nltk
python -m pip install --upgrade git+https://github.com/huggingface/transformers
python -m pip install --upgrade deepspeed
python -m pip install --upgrade tensorboard
python -m pip install --upgrade pybind11
```

Clone a fork of Megatron-DeepSpeed

```
git clone https://github.com/spyysalo/Megatron-DeepSpeed.git
cd Megatron-DeepSpeed
git checkout lumi
cd ..
```

### Data

Download data in JSONL format

```
wget https://a3s.fi/lumi-llm-scaling/wikipedia_20220301.en.train.jsonl
wget https://a3s.fi/lumi-llm-scaling/wikipedia_20220301.en.valid.jsonl
```

Download tokenizer

```
wget https://huggingface.co/gpt2/resolve/main/vocab.json
wget https://huggingface.co/gpt2/resolve/main/merges.txt
```

Convert data to Megatron-DeepSpeed binary format on compute node.
This takes about 30 minutes.

```
./cpu-interactive.sh

source /opt/miniconda3/bin/activate pytorch

mkdir data
for f in wikipedia_20220301.en.{train,valid}.jsonl; do
    python Megatron-DeepSpeed/tools/preprocess_data.py \
        --input $f \
        --output data/$(basename $f .jsonl) \
        --dataset-impl mmap \
        --tokenizer-type GPT2BPETokenizer \
        --vocab vocab.json \
        --merge-file merges.txt \
        --append-eod \
        --workers 128
done

exit
```

**TODO: move data to flash, read from there**

### Small-scale test

```
./gpu-interactive.sh

source /opt/miniconda3/bin/activate pytorch

./smallrun.sh
```

### Schedule batch job

```
pretrain_33B_8_node.sh
[wait 30 min]
throughput.py logs/latest.*
```

This should output approximately

```
samples/sec:	mean	7.5	stdev	0.0	median	7.5	values	11
TFLOPs     :	mean	64.8	stdev	0.3	median	64.8	values	11
```
