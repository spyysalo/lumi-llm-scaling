# GPT-NeoX on LUMI

This directory contains scripts and documentation related to running
[GPT-NeoX](https://github.com/EleutherAI/gpt-neox) on LUMI.

## Quickstart

First create a new directory for your work (see top-level `README`) and
then run the following in that directory:

### Clone this repository

```
git clone https://github.com/spyysalo/lumi-llm-scaling.git
```

Work in this subdirectory

```
cd lumi-llm-scaling/gpt-neox
```

### Setup

Run setup script to create virtual environment.

```
source setup-venv.sh
```

Clone GPT-NeoX repository

```
git clone https://github.com/EleutherAI/gpt-neox.git
```

Install the rest of GPT-NeoX requirements

```
python -m pip install -r gpt-neox/requirements/requirements.txt
```

Downgrade urllib3 to work around a [best-download issue](https://github.com/EleutherAI/best-download/issues/3)

```
python3 -m pip install 'urllib3<2'
```

### Data

Download example data

```
cd gpt-neox/
python prepare_data.py -d data
cd ..
```

### Schedule job

```
./pretrain.sh
```

### Summarize throughput results

```
python3 throughput.py logs/latest.out 
```

This should print approximately

```
samples/sec: mean: 4.6 stdev: 0.1 median: 4.6 (125 values)
TFLOPs     : mean: 66.8 stdev: 1.9 median: 66.9 (125 values)
```
