#!/system/bin/sh
# Copyright (c) 2012, Code Aurora Forum. All rights reserved.
# Copyright (c) 2015, Team Vee. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Code Aurora Forum, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# Update USB serial number from persist storage if present, if not update
# with value passed from kernel command line, if none of these values are
# set then use the default value. This order is needed as for devices which
# do not have unique serial number.
# User needs to set unique usb serial number to persist.usb.serialno
#
serialno=`getprop persist.usb.serialno`
case "$serialno" in
    "")
    serialnum=`getprop ro.serialno`
    case "$serialnum" in
        "");; #Do nothing, use default serial number
        *)
        echo "$serialnum" > /sys/class/android_usb/android0/iSerial
    esac
    ;;
    *)
    echo "$serialno" > /sys/class/android_usb/android0/iSerial
esac

chown root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
chmod 220 /sys/devices/platform/msm_hsusb/gadget/wakeup

#
# Allow USB enumeration with default PID/VID
#
setprop sys.usb.config.extra diag
baseband=`getprop ro.baseband`
echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
usb_config=`getprop persist.sys.usb.config`
case "$usb_config" in
    "" | "adb") #USB persist config not set, select default configuration
        case $target in
            "msm7x27a")
                setprop persist.sys.usb.config diag,serial_smd,serial_tty,rmnet_smd,mass_storage,adb
            ;;
            * )
                case "$baseband" in
                    *)
                         setprop persist.sys.usb.config diag,serial_tty,serial_tty,rmnet_smd,mass_storage,adb
                    ;;
                esac
            ;;
        esac
    ;;
    * ) ;; #USB persist config exists, do nothing
esac

