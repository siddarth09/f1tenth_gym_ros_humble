#!/bin/bash

# F1TENTH Gym ROS2 Humble Installation Script
# Tested on Ubuntu 22.04 + ROS 2 Humble + Python 3.10

set -e  # Exit immediately on any error

echo "=== Step 1: Updating system packages ==="
sudo apt update

echo "=== Step 2: Installing python venv and swig ==="
sudo apt install -y python3.10-venv swig

echo "=== Step 3: Creating and activating Python virtual environment ==="
python3.10 -m venv ~/f1tenth_env
source ~/f1tenth_env/bin/activate
pip install --upgrade pip setuptools

echo "=== Step 4: Installing OpenAI Gym 0.19.0 ==="
cd ~
git clone https://github.com/openai/gym.git
cd gym
git checkout 0.19.0

# Patch setup.py automatically
echo "Patching setup.py..."
sed -i '/tests_require/d' setup.py
sed -i 's/"opencv-python>=3\."/\"opencv-python>=3.0.0\"/' setup.py

pip install -e .

echo "=== Step 5: Installing other Python dependencies ==="
pip install numpy==1.23.5 box2d-py transforms3d pyglet==1.4.11 scipy==1.11.4

echo "=== Step 6: Cloning and installing F1Tenth Gym ==="
cd ~
git clone https://github.com/f1tenth/f1tenth_gym.git
pip install -e ./f1tenth_gym

echo "=== Step 7: Setting up ROS2 workspace ==="
mkdir -p ~/f1ws/src
cd ~/f1ws/src
git clone https://github.com/siddarth09/f1tenth_gym_ros_humble.git

echo "=== Step 8: Fixing map path in sim.yaml ==="
# Replace '~' with /home/username
username=$(whoami)
sed -i "s|~|/home/$username|g" ~/f1ws/src/f1tenth_gym_ros_humble/config/sim.yaml

echo "=== Step 9: Installing ROS2 dependencies ==="
source /opt/ros/humble/setup.bash
cd ~/f1ws
rosdep update
rosdep install -i --from-path src --rosdistro humble -y

echo "=== Step 10: Building the workspace ==="
colcon build

echo "=== INSTALLATION COMPLETE ==="
echo "---------------------------------------------------------"
echo "To launch simulator:"
echo "source ~/f1tenth_env/bin/activate"
echo "source /opt/ros/humble/setup.bash"
echo "source ~/f1ws/install/setup.bash"
echo "ros2 launch f1tenth_gym_ros simulator_launch.py"
echo "---------------------------------------------------------"

