#!/bin/sh

# modify these var if needed
ITRIADV_ROS1_INSTALL_PATH=/opt/ros/noetic
ITRIADV_ROS2_INSTALL_PATH=/opt/ros/galactic
THIS_DIR=$(pwd)
ITRIADV1_DIR=/home/itri/itriadv
ITRIADV2_DIR=/home/itri/itriadv2
BRIDGE_DIR=/home/itri/bridge_ws

clean_all_ros_var() {
    unset "${!ROS@}"
}

clean_all_ros_var

# build msgs under itriadv
echo "@@@ build msgs under itriadv @@@"
source $ITRIADV_ROS1_INSTALL_PATH/setup.bash
printenv | grep ROS
cd $ITRIADV1_DIR
catkin_make --only-pkg-with-deps msgs

clean_all_ros_var

# build msgs under itriadv2
echo "@@@ build msgs under itriadv2 @@@"
source $ITRIADV_ROS2_INSTALL_PATH/setup.bash
printenv | grep ROS
cp $THIS_DIR/itriadv_custom_msg/mapping_rules.yaml $ITRIADV2_DIR/src/msgs/
cp $THIS_DIR/itriadv_custom_msg/CMakeLists.txt $ITRIADV2_DIR/src/msgs/
cp $THIS_DIR/itriadv_custom_msg/package.xml $ITRIADV2_DIR/src/msgs/
cd $ITRIADV2_DIR
colcon build --symlink-install --packages-select msgs

clean_all_ros_var

# build ros1_bridge under bridge_ws
echo "@@@ build ros1_bridge under bridge_ws @@@"
source $ITRIADV_ROS1_INSTALL_PATH/setup.bash 
source $ITRIADV_ROS2_INSTALL_PATH/setup.bash 
source $ITRIADV1_DIR/devel/setup.bash
source $ITRIADV2_DIR/install/setup.bash
rm -rf $BRIDGE_DIR/log $BRIDGE_DIR/build $BRIDGE_DIR/install 
printenv | grep ROS
mkdir -p $BRIDGE_DIR/src
cd $BRIDGE_DIR/src/

if [[ ! -f "$BRIDGE_DIR/src/ros1_bridge" ]]; then
    git clone git@github.com:ros2/ros1_bridge.git
fi
cd $BRIDGE_DIR
colcon build --symlink-install --packages-select ros1_bridge --cmake-force-configure

# Execute ros1_bridge
echo "@@@ Execute ros1_bridge @@@"
source $BRIDGE_DIR/install/setup.bash
ros2 run ros1_bridge dynamic_bridge --bridge-all-topics
