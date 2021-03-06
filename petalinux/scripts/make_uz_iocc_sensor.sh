# ----------------------------------------------------------------------------
#       _____
#      *     *
#     *____   *____
#    * *===*   *==*
#   *___*===*___**  AVNET
#        *======*
#         *====*
# ----------------------------------------------------------------------------
# 
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
# 
#  Please direct any questions to the UltraZed community support forum:
#     http://www.ultrazed.org/forum
# 
#  Product information is available at:
#     http://www.ultrazed.org/product/ultrazed-EG
# 
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2016 Avnet, Inc.
#                              All rights reserved.
# 
# ----------------------------------------------------------------------------
# 
#  Create Date:         Nov 21, 2016
#  Design Name:         Avnet UltraZed-3EG SOM Sensors Reference Design
#  Module Name:         make_uz_iocc_sensor.tcl
#  Project Name:        Avnet UltraZed-3EG SOM Sensors Reference Design
#  Target Devices:      Xilinx Zynq Ultrascale MPSoC
#  Hardware Boards:     Avnet UltraZed-3EG SOM and IOCC (UZ3EG_IOCC)
# 
#  Tool versions:       Xilinx Vivado 2016.2
# 
#  Description:         Build Script for PicoZed FMC2 Factory Acceptance Test
# 
#  Dependencies:        None
#
#  Revision:            Nov 21, 2016: 1.00 Initial version
#                       Jan 30, 2017: 1.01 Updated to include 
#                                          uz_flash_programming application
# 
# ----------------------------------------------------------------------------

#!/bin/bash

# Set global variables here.
APP_PETALINUX_INSTALL_PATH=/mnt/sdb/petalinux-v2016.2-final
APP_VIVADO_INSTALL_PATH=/mnt/sdb/Xilinx/Vivado/2016.2
BUILD_BOOT_SD_OPTION=yes
FSBL_PROJECT_NAME=zynqmp_fsbl
HDL_HARDWARE_NAME=uz_iocc_sensor_hw
HDL_PROJECT_NAME=uz_iocc_sensor
HDL_PROJECTS_FOLDER=../../../hdl/Projects
HDL_SCRIPTS_FOLDER=../../../hdl/Scripts
PETALINUX_APPS_FOLDER=../../../software/petalinux/apps
PETALINUX_MODULES_FOLDER=../../../software/petalinux/modules
PETALINUX_CONFIGS_FOLDER=../../../software/petalinux/configs
PETALINUX_PROJECTS_FOLDER=../../../software/petalinux/projects
PETALINUX_SCRIPTS_FOLDER=../../../software/petalinux/scripts
START_FOLDER=`pwd`

source_tools_settings ()
{
  # Source the tools settings scripts so that both Vivado and PetaLinux can 
  # be used throughout this build script.
  source ${APP_VIVADO_INSTALL_PATH}/settings64.sh
  source ${APP_PETALINUX_INSTALL_PATH}/settings.sh
}

petalinux_project_restore_boot_config ()
{
  # Restore original PetaLinux project config. Don't forget that the
  # petalinux_project_save_boot_config () should have been called at some
  # point before this function gets called, otherwise there probably is
  # nothing there to restore.
  echo " "
  echo "Restoring original PetaLinux project config ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/
  cp config.orig config
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Restore original U-Boot config. 
  echo " "
  echo "Restoring original U-Boot project config ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot/
  cp config.orig config
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Restore original U-Boot top level configuration.
  echo " "
  echo "Restoring original U-Boot top level configuration..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot
  cp platform-top.h.orig platform-top.h
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Restore original U-Boot environment configuration.
  echo " "
  echo "Restoring original U-Boot environment configuration ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot
  cp platform-auto.h.orig platform-auto.h
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}
}

petalinux_project_save_boot_config ()
{
  # Save original PetaLinux project config.
  echo " "
  echo "Saving original PetaLinux project config ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/
  cp config config.orig
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Save original U-Boot config.
  echo " "
  echo "Saving original U-Boot config ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot/
  cp config config.orig
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Save original U-Boot top level configuration.
  echo " "
  echo "Saving original U-Boot top level configuration..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot
  cp platform-top.h platform-top.h.orig
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Save original U-Boot environment configuration.
  echo " "
  echo "Saving original U-Boot environment configuration ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot
  cp platform-auto.h platform-auto.h.orig
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}
}

petalinux_project_set_boot_config_sd ()
{ 
  # Add support for SD commands to U-Boot top level configuration in which
  # bistream has already been loaded from the BOOT.BIN container file.
  echo " "
  echo "Overwriting U-Boot platform-auto.h configuration ..."
  echo " "
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/u-boot
  cp ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/u-boot/platform-auto.h.UZ3EG_IOCC platform-auto.h
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}
}

create_petalinux_bsp ()
{ 
  # This function is responsible for creating a PetaLinux BSP around the
  # hardware platform specificed in HDL_PROJECT_NAME variable and build
  # the PetaLinux project within the folder specified by the 
  # PETALINUX_PROJECT_NAME variable.
  #
  # When complete, the BSP should boot from SD card 

  # Check to see if the PetaLinux projects folder even exists because when
  # you clone the source tree from Avnet Github, the projects folder is not
  # part of that tree.
  if [ ! -d ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER} ]; then
    # Create the PetaLinux projects folder.
    mkdir ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}
  fi

  # Change to PetaLinux projects folder.
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}

  # Create the PetaLinux project.
  petalinux-create --type project --template zynqMP --name ${PETALINUX_PROJECT_NAME}

  # Create the hardware definition folder.
  mkdir -p ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/hw_platform

  # Import the hardware definition files and hardware platform bitstream from
  # implemented system products folder.
  cd ${START_FOLDER}/${HDL_PROJECTS_FOLDER}

  echo " "
  echo "Importing hardware definition ${HDL_HARDWARE_NAME} from impl_1 folder ..."
  echo " "

  cp -f ${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}/${HDL_PROJECT_NAME}.runs/impl_1/${HDL_PROJECT_NAME}_wrapper.sysdef \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/hw_platform/${HDL_HARDWARE_NAME}.hdf

  echo " "
  echo "Importing hardware bitstream ${HDL_HARDWARE_NAME} from impl_1 folder ..."
  echo " "

  cp -f ${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}/${HDL_PROJECT_NAME}.runs/impl_1/${HDL_PROJECT_NAME}_wrapper.bit \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/hw_platform/system_wrapper.bit

  # Change directories to the hardware definition folder for the PetaLinux
  # project, at this point the .hdf file must be located in this folder 
  # for the petalinux-config step to be successful.
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Import the hardware description into the PetaLinux project.
  petalinux-config --oldconfig --get-hw-description=./hw_platform/ -p ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}
 
  # Overwrite the PetaLinux project config with the revision controlled source
  # config.  Use a board specific configuration if available, if not, use the 
  # generic one by default.
  echo " "
  echo "Overwriting PetaLinux project config ..."
  echo " "
  if [ -f ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/config.UZ3EG_IOCC_SENSOR ] 
    then
    cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/config.UZ3EG_IOCC_SENSOR \
    ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/config
  else
    cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/config.generic \
    ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/config
  fi

  # Create a PetaLinux application named demo_setup.
  petalinux-create --type apps --name demo_setup --enable

  # Copy the demo_setup application information over to the demo_setup
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/demo_setup/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/demo_setup

  # Create a PetaLinux application named generic_buffer.
  petalinux-create --type apps --name generic_buffer --enable

  # Copy the generic_buffer application information over to the generic_buffer
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/generic_buffer/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/generic_buffer

  # Create a PetaLinux application named hts221_sensor.
  petalinux-create --type apps --name hts221_sensor --enable

  # Copy the hts221_sensor folder over to the hts221_sensor 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/hts221_sensor/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/hts221_sensor

  # Create a PetaLinux application named IIoT_Quickstart_Demo.
  petalinux-create --type apps --name IIoT_Quickstart_Demo --enable

  # Copy the IIoT_Quickstart_Demo folder over to the IIoT_Quickstart_Demo 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/IIoT_Quickstart_Demo/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/IIoT_Quickstart_Demo

  # Create a PetaLinux application named lis3mdl_sensor.
  petalinux-create --type apps --name lis3mdl_sensor --enable

  # Copy the lis3mdl_sensor folder over to the lis3mdl_sensor 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/lis3mdl_sensor/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/lis3mdl_sensor

  # Create a PetaLinux application named lps25hb_sensor.
  petalinux-create --type apps --name lps25hb_sensor --enable

  # Copy the lps25hb_sensor folder over to the lps25hb_sensor 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/lps25hb_sensor/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/lps25hb_sensor

  # Create a PetaLinux application named max44000_sensor.
  petalinux-create --type apps --name max44000_sensor --enable

  # Copy the max44000_sensor folder over to the max44000_sensor 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/max44000_sensor/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/max44000_sensor

  # Create a PetaLinux application named pwm_devmem.
  petalinux-create --type apps --name pwm_devmem --enable

  # Copy the pwm_devmem folder over to the pwm_devmem 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/pwm_devmem/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/pwm_devmem

  # Create a PetaLinux application named pwm_uio.
  petalinux-create --type apps --name pwm_uio --enable

  # Copy the pwm_uio folder over to the pwm_uio 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/pwm_uio/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/pwm_uio

  # Create a PetaLinux application named sensor_plnx_init.
  petalinux-create --type apps --name sensor_plnx_init --enable

  # Copy the sensor_plnx_init folder over to the sensor_plnx_init 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/sensor_plnx_init/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/sensor_plnx_init

  # Create a PetaLinux application named setup_eth1.
  petalinux-create --type apps --name setup_eth1 --enable

  # Copy the setup_eth1 folder over to the setup_eth1 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/setup_eth1/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/setup_eth1

  # Create a PetaLinux application named spidev_test.
  petalinux-create --type apps --name spidev_test --enable

  # Copy the spidev_test folder over to the spidev_test 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/spidev_test/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/spidev_test

  # Create a PetaLinux application named start_demo_apps.
  petalinux-create --type apps --name start_demo_apps --enable

  # Copy the start_demo_apps folder over to the start_demo_apps 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/start_demo_apps/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/start_demo_apps

  # Create a PetaLinux application named uz_flash_programming.
  petalinux-create --type apps --name uz_flash_programming --enable

  # Copy the uz_flash_programming folder over to the uz_flash_programming 
  # application folder.
  cp -rf ${START_FOLDER}/${PETALINUX_APPS_FOLDER}/uz_flash_programming/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/apps/uz_flash_programming/

  # Create a PetaLinux kernel module named hts221.
  petalinux-create --type modules --name hts221 --enable

  # Copy the hts221 folder over to the hts221 module folder.
  cp -rf ${START_FOLDER}/${PETALINUX_MODULES_FOLDER}/hts221/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/modules/hts221

  # Create a PetaLinux kernel module named lis3mdl.
  petalinux-create --type modules --name lis3mdl --enable

  # Copy the lis3mdl folder over to the lis3mdl module folder.
  cp -rf ${START_FOLDER}/${PETALINUX_MODULES_FOLDER}/lis3mdl/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/modules/lis3mdl

  # Create a PetaLinux kernel module named lps25.
  petalinux-create --type modules --name lps25 --enable

  # Copy the lps25 folder over to the lps25 module folder.
  cp -rf ${START_FOLDER}/${PETALINUX_MODULES_FOLDER}/lps25/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/modules/lps25

  # Create a PetaLinux kernel module named max44000.
  petalinux-create --type modules --name max44000 --enable

  # Copy the max44000 folder over to the max44000 module folder.
  cp -rf ${START_FOLDER}/${PETALINUX_MODULES_FOLDER}/max44000/* \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/modules/max44000


  # Modify the stock First Stage Boot Loader application source code to 
  # include additional patches specific to the board hardware.

  echo " "
  echo "Modifying stock FSBL code with patches for ${HDL_BOARD_NAME} hardware ..."
  echo " "

  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/components/bootloader/zynqmp_fsbl/
  patch < ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/bootloader/psu_init.c.patch.UZ3EG_IOCC
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}

  # Overwrite the rootfs component config with the revision controlled source
  # config.
  echo " "
  echo "Overwriting rootfs config ..."
  echo " "
  cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/rootfs/config.UZ3EG_IOCC_SENSOR \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/rootfs/config

  # Overwrite the top level devicetree source with the revision controlled
  # source file.
  echo " "
  echo "Overwriting top level devicetree source ..."
  echo " "
  cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/device-tree/system-top.dts.UZ3EG_IOCC_SENSOR \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/device-tree/system-top.dts

  # Overwrite the config level devicetree source with the revision controlled
  # source file.
  echo " "
  echo "Overwriting config level devicetree source ..."
  echo " "
  cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/device-tree/system-conf.dtsi.UZ3EG_IOCC_SENSOR \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/device-tree/system-conf.dtsi

  # Overwrite the kernel component config with the revision controlled source
  # config.
  echo " "
  echo "Overwriting kernel config ..."
  echo " "
  cp -rf ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/kernel/config.UZ3EG_IOCC_SENSOR \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/subsystems/linux/configs/kernel/config

  # Prepare to modify project configurations.
  petalinux_project_save_boot_config

  # If the SD boot option is set, then perform the steps needed to  
  # build BOOT.BIN for booting from SD with the bistream loaded from 
  # the BOOT.BIN container image on the SD card.
  if [ "$BUILD_BOOT_SD_OPTION" == "yes" ]
  then
    # Modify the project configuration for sd boot.
    petalinux_project_set_boot_config_sd

    # Make sure that intermediary files get cleaned up.
    petalinux-build -x distclean

    # Build PetaLinux project.
    petalinux-build 

    # Create boot image which does not contain the bistream image.
    petalinux-package --boot --fsbl images/linux/${FSBL_PROJECT_NAME}.elf --fpga hw_platform/system_wrapper.bit --uboot --force

    # Copy the boot.bin file and name the new file BOOT_SD.BIN
    cp ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/BOOT.BIN \
    ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/BOOT_SD.bin
  fi
  
  # Change to HDL scripts folder.
  cd ${START_FOLDER}/${HDL_SCRIPTS_FOLDER}

  # Clean the hardware project output products using the HDL TCL scripts.
  echo "set argv [list board=${HDL_BOARD_NAME} project=${HDL_PROJECT_NAME} clean=yes jtag=yes version_override=yes]" > cleanup.tcl
  echo "set argc [llength \$argv]" >> cleanup.tcl
  echo "source ./make.tcl -notrace" >> cleanup.tcl

  # Launch vivado in batch mode to clean output products from the hardware platform.
  vivado -mode batch -source cleanup.tcl

  # Change to PetaLinux project folder.
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/

  # Package the bitstream within the PetaLinux pre-built folder.
  petalinux-package --prebuilt --fpga hw_platform/system_wrapper.bit

  # Copy the template Makefile over to the PetaLinux project folder. This 
  # Makefile template can later be customized as desired. 
  cp -f ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/Makefile \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/

  # Rename the pre-built bitstream file to download.bit so that the default 
  # format for the petalinux-boot command over jtag will not need the bit file 
  # specified explicitly.
  mv -f pre-built/linux/implementation/system_wrapper.bit \
  pre-built/linux/implementation/download.bit

  # Change to PetaLinux projects folder.
  cd ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/

  # Copy the BOOT_SD.BIN to the pre-built images folder.
  cp ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/images/linux/BOOT_SD.bin \
  ${START_FOLDER}/${PETALINUX_PROJECTS_FOLDER}/${PETALINUX_PROJECT_NAME}/pre-built/linux/images/

  # Package the hardware source into a BSP package output.
  petalinux-package --bsp -p ${PETALINUX_PROJECT_NAME} \
  --hwsource ${START_FOLDER}/${HDL_PROJECTS_FOLDER}/${HDL_PROJECT_NAME}/${HDL_BOARD_NAME}/ \
  --output ${PETALINUX_PROJECT_NAME} --force

  # Append the template Makefile to the PetaLinux BSP package. 
  gzip -dc ${PETALINUX_PROJECT_NAME}.bsp >${PETALINUX_PROJECT_NAME}.tar
  cp -f ${START_FOLDER}/${PETALINUX_CONFIGS_FOLDER}/Makefile .
  tar --append ${PETALINUX_PROJECT_NAME}/Makefile -f ${PETALINUX_PROJECT_NAME}.tar
  gzip -c ${PETALINUX_PROJECT_NAME}.tar > ${PETALINUX_PROJECT_NAME}.bsp
  rm -f Makefile
  rm -f ${PETALINUX_PROJECT_NAME}.tar

  # Change to PetaLinux scripts folder.
  cd ${START_FOLDER}/${PETALINUX_SCRIPTS_FOLDER}
}

main_make_function ()
{
  # This function is responsible for first creating all of the hardware
  # platforms needed for generating PetaLinux BSPs and once the hardware
  # platforms are ready, they can be specificed in HDL_BOARD_NAME variable 
  # before the call to create_petalinux_bsp.
  #
  # Once the PetaLinux BSP creation is complete, a BSP package file with the
  # name specified in the PETALINUX_PROJECT_NAME variable can be distributed
  # for use to others.

  #
  # Create the hardware platforms for the supported targets.
  #

  # Change to HDL scripts folder.
  cd ${START_FOLDER}/${HDL_SCRIPTS_FOLDER}

  # Launch vivado in batch mode to build hardware platforms for target
  # boards.
  vivado -mode batch -source make_${HDL_PROJECT_NAME}.tcl

  #
  # Create the PetaLinux BSP for the UZ3EG_IOCC target.
  #
  HDL_BOARD_NAME=UZ3EG_IOCC
  PETALINUX_PROJECT_NAME=uz3eg_iocc_sensor_2016_2
  create_petalinux_bsp

}

# First source any tools scripts to setup the environment needed to call both
# PetaLinux and Vivado from this make script.
source_tools_settings

# Call the main_make_function declared above to start building everything.
main_make_function

