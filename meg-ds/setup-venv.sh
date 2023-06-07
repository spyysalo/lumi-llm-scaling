#!/bin/bash

# Set up virtual environment for Megatron-DeepSpeed pretrain_gpt.py.

# This script creates the directories venv and apex. If either of
# these exists, ask to delete.
for p in venv apex; do
    if [ -e "$p" ]; then
	read -n 1 -r -p "$p exists. OK to remove? [y/n] "
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing $p."
	    rm -rf "$p"
	else
            echo "Exiting."
            exit 1
	fi
    fi
done

# Load modules
module load cray-python
module load LUMI/22.08 partition/G rocm/5.2.3

module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
module load aws-ofi-rccl/rocm-5.2.3

# Create and activate venv
python -m venv venv
source venv/bin/activate

# Upgrade pip etc.
python -m pip install --upgrade pip setuptools wheel

# Install pip packages
python -m pip install --upgrade torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
# numpy 1.24.0 or greater breaks due to float deprecation
python -m pip install --upgrade numpy==1.22.4 datasets evaluate accelerate scikit-learn nltk
python -m pip install --upgrade git+https://github.com/huggingface/transformers
python -m pip install --upgrade deepspeed==0.8.1
python -m pip install --upgrade tensorboard

# Install apex on a GPU node
git clone https://github.com/ROCmSoftwarePlatform/apex/

# Use specific working commit (no longer needed as of May 2023)
#cd apex
#git checkout 5de49cc90051adf094920675e1e21175de7bad1b
#cd -

mkdir -p logs
cat <<EOF > install_apex.sh
#!/bin/bash
#SBATCH --account=project_462000273
#SBATCH --cpus-per-task=20
#SBATCH --partition=standard-g
#SBATCH --gres=gpu:mi250:1
#SBATCH --time=1:00:00
#SBATCH --output=logs/install_apex.out
#SBATCH --error=logs/install_apex.err

module load cray-python
module load LUMI/22.08 partition/G rocm/5.2.3

module use /pfs/lustrep2/projappl/project_462000125/samantao-public/mymodules
module load aws-ofi-rccl/rocm-5.2.3

source venv/bin/activate

cd apex
python setup.py install --cpp_ext --cuda_ext
EOF

echo "Installing apex on a GPU node. This is likely to take around 30 min."
time sbatch --wait install_apex.sh
