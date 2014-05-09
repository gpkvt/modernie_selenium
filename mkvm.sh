#!/bin/bash

# Debug
#set -x
#set -e

# Config; See readme for details.
java_exe="jre-7u55-windows-i586.exe"
firefox_exe="Firefox Setup 24.5.0esr.exe"
chrome_exe="GoogleChromeStandaloneEnterprise.msi"
selenium_jar="selenium-server-standalone-2.41.0.jar"

nic_bridge="eth2"
vm_path="/srv/VMs/"
vm_mem="768"
vm_mem_xp="512"
deuac_iso="/opt/Tools/deuac.iso"
tools_path="/opt/Tools/"
selenium_path="/opt/Tools/selenium_conf/"
ie_cache_reg="/opt/Tools/ie_disablecache.reg"
ie_protectedmode_reg="/opt/Tools/ie_protectedmode.reg"
log_path="/home/vbox/"
vbox_user="vbox"
mailto="root"
create_snapshot=False

# Basic-Checks.
if [ "${1}" = "--help" ]; then
  echo "Usage: $0 path_to_ova [--delete VM-Name/UID]"
  exit 0
fi

if [ -z "${1}" ]; then
  echo "Appliance-Path is missing..."
  exit 1
fi

if [ ! -f "${1}" ]; then
  echo "Appliance ${1} not found..."
  exit 1
fi

if [ ! $(which VBoxManage) ]; then
  echo "VBoxManage not found..."
  exit 1
fi

if [ "${USER}" != "${vbox_user}" ]; then
  echo "This script must be run by user \'${vbox_user}\'..."
  exit 1
fi

# Init; Do not change.
appliance=${1}
vm_name=False
vm_pretty_name=False
fatal=False
error=False
warning=False

# Write Logfile and STDOUT.
log() {
  echo ${1} | tee -a "${log_path}${vm_pretty_name}.log"
}

# Error-Handling.
chk() {
  if [ "${2}" != "0" ]; then
    if [ "${1}" = "fatal" ]; then
      log "[FATAL] ${3}"
      fatal=True
      sendmessage
      exit ${2}
    fi
    if [ "${1}" = "skip" ]; then
      log "[WARNING] ${3}"
      warning=True
    fi
    if [ "${1}" = "error" ]; then
      log "[ERROR] ${3}"
      error=True
    fi
  else
    log "[OK]"
  fi
}

# Send Status-Mail.
sendmessage() {
  if [ ! -z ${mailto} ]; then
    subject_prefix="SUCCESS"
    if [ "${warning}" = "True" ]; then
      subject_prefix="WARNING"
    fi
    if [ "${error}" = "True" ]; then
      subject_prefix="ERROR"
    fi
    cat "${log_path}${vm_pretty_name}.log" | mail -s "${subject_prefix}: ${vm_name}" ${mailto}
    rm "${log_path}${vm_pretty_name}.log"
  fi
}

# Get VM OS-Type.
execute_os_specific() {
  case "${vm_os_type}" in
    WindowsXP)
      ${1}_xp
    ;;
    WindowsVista)
      ${1}_wv
    ;;
    Windows7)
      ${1}_w7
    ;;
    Windows8*)
      ${1}_w8
    ;;
    *)
      chk skip 1 "Unexpected OS-Type, skipping ${1}..."
    ;;
  esac
}

# Check if the VM is still running.
check_shutdown() {
  counter=0
  echo -n "Waiting for shutdown"
  while $(VBoxManage showvminfo "${1}" | grep -q 'running'); do
    echo -n "."
    sleep 1
    let counter=counter+1
    if [ ${counter} -ge 120 ]; then
      chk skip 1 "Unable to shutdown/restart..."
      break
    fi
  done
  echo ""
  waiting 5
}

# Print some dots.
waiting() {
  counter=0
  echo -n "Waiting ${1} seconds"
  while [ ${counter} -lt ${1} ]; do
    echo -n "."
    let counter=counter+1
    sleep 1
  done
  echo ""
}

# Get informations about the given Appliance (Name, OS-Type, IE-Version)
get_vm_info() {
  vm_info=$(VBoxManage import "${appliance}" -n)
  chk fatal $? "Error getting Appliance Info"

  vm_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}')
  vm_pretty_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}' | sed 's/_/-/g' | sed 's/ //g' | sed 's/\.//g')
  vm_os_type=$(echo "${vm_info}" | grep 'Suggested OS type' | awk -F'"' '{print $2}')
  vm_ie=$(echo "${vm_name}" | awk -F' -' '{print $1}')
}

#Internal: Helper-Functions to install the Appliance (called by import_vm)
ex_import_vm_xp() {
  VBoxManage import "${appliance}" --vsys 0 --memory ${vm_mem_xp}
  chk fatal $? "Could not import VM"
}

ex_import_vm_w7() {
  VBoxManage import "${appliance}" --vsys 0 --memory ${vm_mem}
  chk fatal $? "Could not import VM"
}

ex_import_vm_wv() {
  ex_import_vm_w7
}

ex_import_vm_w8() {
  ex_import_vm_w7
}

# Import the given Appliance-File; OS-Specific
import_vm() {
  log "Importing ${appliance} as ${vm_name}..."
  execute_os_specific ex_import_vm
}

# Set VM Network-Config.
set_network_config() {
  log "Setting network bridge ${nic_bridge}..."
  VBoxManage modifyvm "${vm_name}" --nic1 bridged --bridgeadapter1 ${nic_bridge}
  chk error $? "Could not set Bridge"
}

# Find and set free Port for RDP-Connection.
set_rdp_config() {
  log "Setting VRDE-Port ${vrdeport}..."
  vrdeports=$(find "/srv/VMs/" -name *.vbox -print0 | xargs -0 grep "TCP/Ports" | awk -F'"' '{print $4}' | sort)
  for ((i=9000;i<=10000;i++)); do
    echo ${vrdeports} | grep -q ${i}
    if [[ $? -ne 0 ]]; then
      vrdeport=$i
      break
    fi
  done

  if [ -z "${vrdeport}" ]; then
    vrdeport="9000"
  fi
  if [[ ${vrdeport} < 9000 ]]; then
    vrdeport="9000"
  fi
  if [ "${vrdeport}" = "10000" ]; then
    chk skip $? "Could not find free VRDE-Port"
  else
    VBoxManage modifyvm "${vm_name}" --vrde on --vrdeport ${vrdeport}
    chk error $? "Could not set VRDE-Port"
  fi
}

# Internal: Helper-Functions to disable UAC (called by disable_uac)
ex_disable_uac_w7() {
  log "Mounting Disk..."
  VBoxManage storageattach "${vm_name}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium ${deuac_iso}
  chk fatal $? "Could not mount ${deuac_iso}"
  log "Disabling UAC..."
  VBoxManage startvm "${vm_name}" --type headless
  chk fatal $? "Could not start VM to disable UAC"
  waiting 60
  check_shutdown ${vm_name}
  log "Removing Disk..."
  VBoxManage storageattach "${vm_name}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium none
  chk fatal $? "Could not unmount ${deuac_iso}"
}

ex_disable_uac_wv() {
  ex_disable_uac_w7
}

ex_disable_uac_w8() {
  ex_disable_uac_w7
}

ex_disable_uac_xp() {
  return 1
}

# Disable UAC; Required to install Java successfully later; OS-Specific
disable_uac() {
  execute_os_specific ex_disable_uac
}

# Start the VM; Wait some seconds afterwards to give the VM time to start up completely.
start_vm() {
  log "Starting VM ${vm_name}..."
  VBoxManage startvm "${vm_name}" --type headless
  chk fatal $? "Could not start VM"
  waiting 60
}

# Internal: Helper-Functions to disable the Windows Firewall (called by disable_firewall)
ex_disable_firewall_xp() {
  log "Disabling Windows XP Firewall..."
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/windows/system32/netsh.exe" --username 'IEUser' --password 'Passw0rd!' -- firewall set opmode mode=DISABLE
  chk error $? "Could not disable Firewall"
}

ex_disable_firewall_w7() {
  log "Disabling Windows Firewall..."
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/windows/system32/netsh.exe" --username 'IEUser' --password 'Passw0rd!' -- advfirewall set allprofiles state off
  chk error $? "Could not disable Firewall"
}

ex_disable_firewall_wv() {
  ex_disable_firewall_w7
}

ex_disable_firewall_w8() {
  ex_disable_firewall_w7
}

# Disable the Windows Firewall; OS-Specific
disable_firewall() {
  execute_os_specific ex_disable_firewall
}

# Create C:\Temp\; Most Functions who copy files to the VM are relying on this folder and will fail is he doesn't exists.
create_temp_path() {
  log "Creating C:/Temp/..."
  VBoxManage guestcontrol "${vm_name}" createdirectory "C:/Temp/" --username 'IEUser' --password 'Passw0rd!'
  chk fatal $? "Could not create C:/Temp/"
}

# Apply registry changes to configure Internet Explorer settings (Protected-Mode, Cache)
set_ie_config() {
  log "Apply IE Protected-Mode Settings..."
  VBoxManage guestcontrol "${vm_name}" copyto "${ie_protectedmode_reg}" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  VBoxManage guestcontrol "${vm_name}" execute --image "C:\\Windows\\Regedit.exe" --username 'IEUser' --password 'Passw0rd!' -- /s "C:\\Temp\\ie_protectedmode.reg"
  chk error $? "Could not apply IE Protected-Mode-Settings"
  log "Disabling IE-Cache..."
  VBoxManage guestcontrol "${vm_name}" copyto "${ie_cache_reg}" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  VBoxManage guestcontrol "${vm_name}" execute --image "C:\\Windows\\Regedit.exe" --username 'IEUser' --password 'Passw0rd!' -- /s "C:\\Temp\\ie_disablecache.reg"
  chk error $? "Could not disable IE-Cache"
}

# Install Java (required by Selenium); We don't use --wait-exit as it may cause trouble with XP-VMs, instead we just wait some time to ensure the Java-Installer can finish.
install_java() {
  log "Installing Java..."
  VBoxManage guestcontrol "${vm_name}" copyto ${tools_path}${java_exe} C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/Temp/${java_exe}" --username 'IEUser' --password 'Passw0rd!' -- /s
  chk error $? "Could not install Java"
  waiting 120
}

# Install Firefox.
install_firefox() {
  log "Installing Firefox..."
  VBoxManage guestcontrol "${vm_name}" copyto "${tools_path}${firefox_exe}" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/Temp/${firefox_exe}" --username 'IEUser' --password 'Passw0rd!' -- /S
  chk error $? "Could not install Firefox"
  waiting 120
}

# Install Chrome-Driver for Selenium
install_chrome_driver() {
  log "Installing Chrome Driver..."
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}chromedriver.exe" C:/Windows/system32/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not install Chrome Driver"
  waiting 5
}

# Install Chrome.
install_chrome() {
  log "Installing Chrome..."
  VBoxManage guestcontrol "${vm_name}" copyto "${tools_path}${chrome_exe}" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/Windows/System32/msiexec.exe" --username 'IEUser' --password 'Passw0rd!' -- /qn /i C:\\Temp\\${chrome_exe}
  chk error $? "Could not install Chrome"
  waiting 120
  install_chrome_driver
}

# Internal: Helper-Functions to Install Selenium (called by install_selenium)
start_selenium_xp() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}selenium.bat" "C:/Documents and Settings/All Users/Start Menu/Programs/Startup/" --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Startup-File"
}

start_selenium_w7() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}selenium.bat" "C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/" --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Startup-File"
}

start_selenium_wv() {
  start_selenium_w7
}

start_selenium_w8() {
  start_selenium_w7
}

config_selenium_xp() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}XP/${vm_ie}/config.json" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Config"
}

config_selenium_w7() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}WIN7/${vm_ie}/config.json" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Config"
}

config_selenium_wv() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}VISTA/${vm_ie}/config.json" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Config"
}

config_selenium_w8() {
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}WIN8/${vm_ie}/config.json" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not copy Selenium-Config"
}

ie11_driver_reg() {
  if [ "${vm_ie}" = "IE11" ]; then
    log "Copy ie11_win32.reg..."
    VBoxManage guestcontrol "${vm_name}" copyto "${tools_path}ie11_win32.reg" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
    chk skip $? "Could not copy ie11_win32.reg"
    ĺog "Setting ie11_win32.reg..."
    VBoxManage guestcontrol "${vm_name}" execute --image "C:\\Windows\\Regedit.exe" --username 'IEUser' --password 'Passw0rd!' -- /s "C:\\Temp\\ie11_win32.reg"
    chk skip $? "Could not set ie11_win32.reg"
  fi
}

# Install Selenium
install_selenium() {
  log "Creating C:/selenium/..."
  VBoxManage guestcontrol "${vm_name}" createdirectory C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk fatal $? "Could not create C:/Selenium/"
  log "Installing Selenium..."
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}${selenium_jar}" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not install Selenium"
  log "Installing IEDriverServer..."
  VBoxManage guestcontrol "${vm_name}" copyto "${selenium_path}IEDriverServer.exe" C:/Windows/system32/ --username 'IEUser' --password 'Passw0rd!'
  chk error $? "Could not install IEDriverServer.exe"
  log "Configure Selenium..."
  execute_os_specific config_selenium
  log "Prepare Selenium-Autostart..."
  execute_os_specific start_selenium
  ie11_driver_reg
}

# Create a Snapshot; Disabled by default.
snapshot_vm() {
  log "Creating Snapshot ${1}..."
  VBoxManage snapshot "${vm_name}" take "${1}"
  chk skip $? "Could not create Snapshot ${1}"
}

# Reboot the VM; Ensure to wait some time after sending the reboot-Command so that the machine can start up before other actions will applied.
# shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
reboot_vm() {
  log "Rebooting..."
  VBoxManage guestcontrol "${vm_name}" execute --image C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /r /f
  chk skip $? "Could not reboot"
  waiting 90
}

# Shutdown the VM and control the success via showvminfo; shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
shutdown_vm() {
  log "Shutting down..."
  VBoxManage guestcontrol "${1}" execute --image C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f
  chk skip $? "Could not shut down"
  check_shutdown ${1}
}

# Remove the given Machine from VBox and delete all associated files. Shut down the VM beforehand, if needed.
delete_vm() {
  log "Removing ${1}..."
  if [ ! $(VBoxManage showvminfo "${1}" | grep -q 'running') ]; then
    shutdown_vm "${1}"
    waiting 30
  fi
  VBoxManage unregistervm "${1}" --delete
  chk skip $? "Could not remove VM ${1}"
  waiting 10
}

# Change the Hostname of the VM; Avoids duplicate Names on the Network in case you set up several instances of the same Appliance.
# We copy the rename.bat because the VBox exec doesn't provide the needed Parameters in a way wmic.exe is able to apply correctly.
# Also WinXP usually fails to set the name, you can use C:\Temp\rename.bat to set it manually on the VM. Make sure to restart afterwards.
rename_vm() {
  case ${vm_name} in
    IE6*WinXP*)
      vm_orig_name="ie6winxp"
    ;;
    IE8*WinXP*)
      vm_orig_name="ie8winxp"
    ;;
    IE7*Vista*)
      vm_orig_name="IE7Vista"
    ;;
    IE8*Win7*)
      vm_orig_name="IE8Win7"
    ;;
    IE9*Win7*)
      vm_orig_name="IE9Win7"
    ;;
    IE10*Win7*)
      vm_orig_name="IE10Win7"
    ;;
    IE11*Win7*)
      vm_orig_name="IE11Win7"
    ;;
    IE10*Win8*)
      vm_orig_name="IE10Win8"
    ;;
    IE11*Win8*)
      vm_orig_name="IE11Win8_1"
    ;;
    *)
      chk skip 1 "Could not find hostname, skip renaming..."
      return 1
    ;;
  esac
  log "Preparing to change Hostname ${vm_orig_name} to ${vm_pretty_name}..."
  echo 'c:\windows\system32\wbem\wmic.exe computersystem where caption="'${vm_orig_name}'" call rename "'${vm_pretty_name}'"' > /tmp/rename.bat
  chk skip $? "Could not create rename.bat"
  log "Copy rename.bat..."
  VBoxManage guestcontrol "${vm_name}" copyto "/tmp/rename.bat" C:/Temp/ --username 'IEUser' --password 'Passw0rd!'
  chk skip $? "Could not copy rename.bat"
  log "Launch rename.bat..."
  VBoxManage guestcontrol "${vm_name}" execute --image "C:/Temp/rename.bat" --username 'IEUser' --password 'Passw0rd!'
  chk skip $? "Could not change Hostname"
  waiting 5
}

configure_clipboard() {
  log "Changing Clipboard-Mode to bidirectional..."
  VBoxManage controlvm "${vm_name}" clipboard bidirectional
  chk skip $? "Could not set Clipboard-Mode"
  waiting 5
}

# Check if --delete was given as second parameter to this script. The VM-Name is expected to be the third parameter.
# If no VM-Name is given --delete will be ignored.
if [ "${2}" = "--delete" ]; then
  if [ ! -z "${3}" ]; then
    delete_vm "${3}"
  else
    log "Delete VM"
    chk skip "--delete was given, but no VM, skipping..."
  fi
fi

get_vm_info
import_vm
set_network_config
set_rdp_config
disable_uac
start_vm
disable_firewall
create_temp_path
rename_vm
set_ie_config
install_java
install_firefox
install_chrome
install_selenium
configure_clipboard

if [ "${create_snapshot}" = "True" ]; then
  shutdown_vm
  snapshot_vm "Selenium"
  start_vm
else
  reboot_vm
fi

sendmessage
