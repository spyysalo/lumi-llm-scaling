# Megatron-DeepSpeed on LUMI

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
cd lumi-llm-scaling/meg-ds
```

### Setup

Run setup script to create virtual environment. This takes about 30 minutes.

```
./setup-venv.sh 
```

Clone a fork of Megatron-DeepSpeed

```
git clone https://github.com/TurkuNLP/Megatron-DeepSpeed.git
cd Megatron-DeepSpeed
git checkout 6732bc9
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
../scripts/cpu-interactive.sh 

module load cray-python
source venv/bin/activate

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

### Schedule batch job

```
sbatch pretrain_33B_8_node.sh 
```

### Summarize throughput results

After allowing the job to run for 30 min:

```
python3 throughput.py logs/latest.out
```

This should print approximately

```
samples/sec:	mean	8.4	stdev	0.0	median	8.4	values	11
TFLOPs     :	mean	72.3	stdev	0.0	median	72.3	values	11
```

### Other model sizes

7B:

```
sbatch pretrain_7B_4_node.sh
[wait 30 min]
python3 throughput.py logs/latest.out 
samples/sec:	mean	19.4	stdev	0.1	median	19.4	values	11
TFLOPs     :	mean	70.9	stdev	0.3	median	71.0	values	11
```

65B:

```
sbatch pretrain_65B_8_node.sh
[wait 30 min]
python3 throughput.py logs/latest.out 
samples/sec: mean: 4.0 stdev: 0.0 median: 4.0 (5 values)
TFLOPs     : mean: 69.3 stdev: 0.1 median: 69.3 (5 values)
```

175B:

```
sbatch pretrain_175B_16_node.sh
[wait 30 min]
python3 throughput.py logs/latest.out 
samples/sec: mean: 3.0 stdev: 0.0 median: 3.0 (3 values)
TFLOPs     : mean: 67.0 stdev: 0.2 median: 66.9 (3 values)
```
