#!/bin/bash
# install python in debian
sudo apt-get install software-properties-common
sudo apt-add-repository universe
sudo apt-get update
sudo apt install -y python-dev python-pip
sudo pip install -U virtualenv  # system-wide install

# create virtual environment
virtualenv --system-site-packages -p python2.7 ./venv

source ./venv/bin/activate  # sh, bash, ksh, or zsh
pip install --upgrade pip

pip list  # show packages installed within the virtual environment

# install tensorflow
pip install --upgrade tensorflow
python -c "import tensorflow as tf; tf.enable_eager_execution(); print(tf.reduce_sum(tf.random_normal([1000, 1000])))"

sudo apt-get install -y python-pil python-numpy
sudo pip install matplotlib

export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

chmod +x test_setup.sh
sh ./test_setup.sh
echo "Model tests complete"

deactivate  # don't exit until you're done using TensorFlow
