# BigCode Megatron-LM on LUMI

This directory contains scripts and documentation related to running the
[BigCode fork of Megatron-LM](https://github.com/microsoft/Megatron-DeepSpeed)
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
cd lumi-llm-scaling/bc-meg-lm
```

### Setup

Run setup script to create virtual environment. This takes about 30 minutes.

```
./setup-venv.sh 
```

Clone the fork of Megatron-LM

```
git clone https://github.com/mayank31398/BigCode-Megatron-LM.git
cd BigCode-Megatron-LM
git checkout ontocord
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

Convert data to Megatron binary format on compute node.
This takes about 30 minutes.

```
../scripts/cpu-interactive.sh 

module load cray-python
source venv/bin/activate

mkdir data
for f in wikipedia_20220301.en.{train,valid}.jsonl; do
    python BigCode-Megatron-LM/tools/preprocess_data.py \
        --input $f \
        --output data/$(basename $f .jsonl) \
        --dataset-impl mmap \
        --tokenizer-type GPT2BPETokenizer \
        --vocab vocab.json \
        --merge-file merges.txt \
        --append-eod \
        --workers 128 \
	--chunk-size 25
done

exit
```

**TODO: move data to flash, read from there**

### Schedule batch job

```
sbatch pretrain_33B_8_node.sh 
```

### Summarize throughput results

```
python3 throughput.py logs/latest.out 
```

This should print approximately

```
TODO
```
