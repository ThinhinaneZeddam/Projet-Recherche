#!/bin/sh
osrelease=`cat /proc/sys/kernel/osrelease |awk -F '_' '{print $1}`
CFG_FILE="/tmp/buildroot_cfg.ini"
try_cnt=0

x_motor_max_speed="0"
x_motor_direction="0"
x_motor_forward_direction="1"
x_motor_model=""
x_motor_start_angle="0"
x_motor_end_angle="0"
x_motor_phy_start_angle="0"
x_motor_phy_end_angle="0"
x_motor_construct_master_teeth="0"
x_motor_construct_slave_teeth="0"

y_motor_max_speed="0"
y_motor_direction="0"
y_motor_forward_direction="1"
y_motor_model=""
y_motor_start_angle="0"
y_motor_end_angle="0"
y_motor_phy_start_angle="0"
y_motor_phy_end_angle="0"
y_motor_construct_master_teeth="0"
y_motor_construct_slave_teeth="0"

x_motor_gpio_a="0"
x_motor_gpio_b="0"
x_motor_gpio_c="0"
x_motor_gpio_d="0"
y_motor_gpio_a="0"
y_motor_gpio_b="0"
y_motor_gpio_c="0"
y_motor_gpio_d="0"
x_motor_pwm_set="0"
y_motor_pwm_set="0"
motor_switch_x="0"
motor_switch_y="0"
motor_switch_gpio="0"

PARAM_NUM=30

while [ ! -f $CFG_FILE ]; do
	echo "ispfile is not ready, wait..."
	sleep 1
	let try_cnt++
	if [ $try_cnt == 5 ]
	then
		break
	fi
done

if [ -f $CFG_FILE ]; then
	param_cnt=0
	while read line
	do
		if (!(echo "$line" | grep -n '^;' > /dev/null) && (echo "$line" | grep -n '=' > /dev/null)); then
		    name=${line%=*}
		    value=${line#*=}

		    if [ $name == "CONFIG_X_MOTOR_MAX_SPEED" ]; then
		    	x_motor_max_speed=$value
		    	echo "x_motor_max_speed = $x_motor_max_speed"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_X_MOTOR_DIRECTION" ]; then
		    	x_motor_direction=$value
		    	echo "x_motor_direction = $x_motor_direction"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_FORWARD_DIRECTION" ]; then
		    	x_motor_forward_direction=$value
		    	echo "x_motor_forward_direction = $x_motor_forward_direction"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_MODEL" ]; then
		    	x_motor_model=$value
		    	echo "x_motor_model = $x_motor_model"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_START_ANGLE" ]; then
		    	x_motor_start_angle=$value
		    	echo "x_motor_start_angle = $x_motor_start_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_END_ANGLE" ]; then
		    	x_motor_end_angle=$value
		    	echo "x_motor_end_angle = $x_motor_end_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_PHY_START_ANGLE" ]; then
		    	x_motor_phy_start_angle=$value
		    	echo "x_motor_phy_start_angle = $x_motor_phy_start_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_PHY_END_ANGLE" ]; then
		    	x_motor_phy_end_angle=$value
		    	echo "x_motor_phy_end_angle = $x_motor_phy_end_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_CONSTRUCT_MASTER_TEETH" ]; then
		    	x_motor_construct_master_teeth=$value
		    	echo "x_motor_construct_master_teeth = $x_motor_construct_master_teeth"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_X_MOTOR_CONSTRUCT_SLAVE_TEETH" ]; then
		    	x_motor_construct_slave_teeth=$value
		    	echo "x_motor_construct_slave_teeth = $x_motor_construct_slave_teeth"
		    	let param_cnt++
		    fi

		    if [ $name == "CONFIG_Y_MOTOR_MAX_SPEED" ]; then
		    	y_motor_max_speed=$value
		    	echo "y_motor_max_speed = $y_motor_max_speed"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_DIRECTION" ]; then
		    	y_motor_direction=$value
		    	echo "y_motor_direction = $y_motor_direction"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_FORWARD_DIRECTION" ]; then
		    	y_motor_forward_direction=$value
		    	echo "y_motor_forward_direction = $y_motor_forward_direction"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_MODEL" ]; then
		    	y_motor_model=$value
		    	echo "y_motor_model = $y_motor_model"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_START_ANGLE" ]; then
		    	y_motor_start_angle=$value
		    	echo "y_motor_start_angle = $y_motor_start_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_END_ANGLE" ]; then
		    	y_motor_end_angle=$value
		    	echo "y_motor_end_angle = $y_motor_end_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_PHY_START_ANGLE" ]; then
		    	y_motor_phy_start_angle=$value
		    	echo "y_motor_phy_start_angle = $y_motor_phy_start_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_PHY_END_ANGLE" ]; then
		    	y_motor_phy_end_angle=$value
		    	echo "y_motor_phy_end_angle = $y_motor_phy_end_angle"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_CONSTRUCT_MASTER_TEETH" ]; then
		    	y_motor_construct_master_teeth=$value
		    	echo "y_motor_construct_master_teeth = $y_motor_construct_master_teeth"
		    	let param_cnt++
		    fi
			if [ $name == "CONFIG_Y_MOTOR_CONSTRUCT_SLAVE_TEETH" ]; then
		    	y_motor_construct_slave_teeth=$value
		    	echo "y_motor_construct_slave_teeth = $y_motor_construct_slave_teeth"
		    	let param_cnt++
		    fi

		    if [ $name == "CONFIG_X_MOTOR_GPIO_A" ]; then
		    	x_motor_gpio_a=$value
		    	echo "x_motor_gpio_a = $x_motor_gpio_a"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_X_MOTOR_GPIO_B" ]; then
		    	x_motor_gpio_b=$value
		    	echo "x_motor_gpio_b = $x_motor_gpio_b"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_X_MOTOR_GPIO_C" ]; then
		    	x_motor_gpio_c=$value
		    	echo "x_motor_gpio_c = $x_motor_gpio_c"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_X_MOTOR_GPIO_D" ]; then
		    	x_motor_gpio_d=$value
		    	echo "x_motor_gpio_d = $x_motor_gpio_d"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_GPIO_A" ]; then
		    	y_motor_gpio_a=$value
		    	echo "y_motor_gpio_a = $y_motor_gpio_a"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_GPIO_B" ]; then
		    	y_motor_gpio_b=$value
		    	echo "y_motor_gpio_b = $y_motor_gpio_b"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_GPIO_C" ]; then
		    	y_motor_gpio_c=$value
		    	echo "y_motor_gpio_c = $y_motor_gpio_c"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_GPIO_D" ]; then
		    	y_motor_gpio_d=$value
		    	echo "y_motor_gpio_d = $y_motor_gpio_d"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_X_MOTOR_PWM_SET" ]; then
		    	x_motor_pwm_set=$value
		    	echo "x_motor_pwm_set = $x_motor_pwm_set"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_Y_MOTOR_PWM_SET" ]; then
		    	y_motor_pwm_set=$value
		    	echo "y_motor_pwm_set = $y_motor_pwm_set"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_MOTOR_SWITCH_X" ]; then
		    	motor_switch_x=$value
		    	echo "motor_switch_x = $motor_switch_x"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_MOTOR_SWITCH_Y" ]; then
		    	motor_switch_y=$value
		    	echo "motor_switch_y = $motor_switch_y"
		    	let param_cnt++
		    fi
		    if [ $name == "CONFIG_MOTOR_SWITCH_GPIO" ]; then
		    	motor_switch_gpio=$value
		    	echo "motor_switch_gpio = $motor_switch_gpio"
		    	let param_cnt++
		    fi

		    if [ $param_cnt == $PARAM_NUM ]
			then
				break
			fi
	    fi
	done < $CFG_FILE

	echo "===insmod /lib/modules/$osrelease/motor_driver.ko==="
	insmod /lib/modules/$osrelease/motor_driver.ko \
	CONFIG_X_MOTOR_MAX_SPEED=$x_motor_max_speed \
	CONFIG_X_MOTOR_DIRECTION=$x_motor_direction \
	CONFIG_X_MOTOR_FORWARD_DIRECTION=$x_motor_forward_direction \
	CONFIG_X_MOTOR_MODEL=$x_motor_model \
	CONFIG_X_MOTOR_START_ANGLE=$x_motor_start_angle \
	CONFIG_X_MOTOR_END_ANGLE=$x_motor_end_angle \
	CONFIG_X_MOTOR_PHY_START_ANGLE=$x_motor_phy_start_angle \
	CONFIG_X_MOTOR_PHY_END_ANGLE=$x_motor_phy_end_angle \
	CONFIG_X_MOTOR_CONSTRUCT_MASTER_TEETH=$x_motor_construct_master_teeth \
	CONFIG_X_MOTOR_CONSTRUCT_SLAVE_TEETH=$x_motor_construct_slave_teeth \
	CONFIG_Y_MOTOR_MAX_SPEED=$y_motor_max_speed \
	CONFIG_Y_MOTOR_DIRECTION=$y_motor_direction \
	CONFIG_Y_MOTOR_FORWARD_DIRECTION=$y_motor_forward_direction \
	CONFIG_Y_MOTOR_MODEL=$y_motor_model \
	CONFIG_Y_MOTOR_START_ANGLE=$y_motor_start_angle \
	CONFIG_Y_MOTOR_END_ANGLE=$y_motor_end_angle \
	CONFIG_Y_MOTOR_PHY_START_ANGLE=$y_motor_phy_start_angle \
	CONFIG_Y_MOTOR_PHY_END_ANGLE=$y_motor_phy_end_angle \
	CONFIG_Y_MOTOR_CONSTRUCT_MASTER_TEETH=$y_motor_construct_master_teeth \
	CONFIG_Y_MOTOR_CONSTRUCT_SLAVE_TEETH=$y_motor_construct_slave_teeth \
	CONFIG_X_MOTOR_GPIO_A=$x_motor_gpio_a \
	CONFIG_X_MOTOR_GPIO_B=$x_motor_gpio_b \
	CONFIG_X_MOTOR_GPIO_C=$x_motor_gpio_c \
	CONFIG_X_MOTOR_GPIO_D=$x_motor_gpio_d \
	CONFIG_Y_MOTOR_GPIO_A=$y_motor_gpio_a \
	CONFIG_Y_MOTOR_GPIO_B=$y_motor_gpio_b \
	CONFIG_Y_MOTOR_GPIO_C=$y_motor_gpio_c \
	CONFIG_Y_MOTOR_GPIO_D=$y_motor_gpio_d \
	CONFIG_X_MOTOR_PWM_SET=$x_motor_pwm_set \
	CONFIG_Y_MOTOR_PWM_SET=$y_motor_pwm_set \
	CONFIG_MOTOR_SWITCH_X=$motor_switch_x \
	CONFIG_MOTOR_SWITCH_Y=$motor_switch_y \
	CONFIG_MOTOR_SWITCH_GPIO=$motor_switch_gpio \
	1>/dev/null 2>&1
else
	echo "====================Warning===================="
	echo "== MOTOR_GPIO was not written to flash yet!  =="
	echo "==============================================="
fi

if [ ! -c /dev/x-motor -o ! -c /dev/y-motor ]; then
	sleep 2
	if [ ! -c /dev/x-motor ]; then
		echo "cannot find x-motor, create it..."
		mknod /dev/x-motor c 151 0
	fi
	if [ ! -c /dev/y-motor ]; then
		echo "cannot find y-motor, create it..."
		mknod /dev/y-motor c 151 1
	fi
fi
