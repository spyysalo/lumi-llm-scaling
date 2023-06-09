# BigCode Megatron-LM on LUMI

This directory contains scripts and documentation related to running the [BigCode fork](https://github.com/bigcode-project/Megatron-LM) of [Megatron-LM](https://github.com/microsoft/Megatron-DeepSpeed) on LUMI.

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
git clone https://github.com/spyysalo/Megatron-LM.git
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

Extend vocabulary with [FIM](https://huggingface.co/bigcode/starcoder#fill-in-the-middle) tokens (required by BigCode `preprocess_data.py`)

```
python3 add_fim_tokens.py vocab.json > vocab_with_fim_tokens.json
```

Convert data to Megatron binary format on compute node.
This takes about 30 minutes.

```
../scripts/cpu-interactive.sh 

module load cray-python
source venv/bin/activate

mkdir data
for f in wikipedia_20220301.en.{train,valid}.jsonl; do
    python Megatron-LM/tools/preprocess_data.py \
        --input $f \
        --output data/$(basename $f .jsonl) \
        --dataset-impl mmap \
        --tokenizer-type GPT2BPETokenizer \
        --vocab vocab_with_fim_tokens.json \
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
tokens/sec/gpu: mean: 177.1 stdev: 15.6 median: 182.8 (7 values)
TFLOPs     : mean: 40.5 stdev: 3.6 median: 41.8 (7 values)
```
