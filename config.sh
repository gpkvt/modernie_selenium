# Config; See readme for details.
java_exe="jre-8u25-windows-i586.exe"
firefox_exe="Firefox Setup 34.0.5.exe"
chrome_exe="ChromeStandaloneSetup.exe"
selenium_jar="selenium-server-standalone-2.44.0.jar"

if [ $(uname) == "Darwin" ]
then
  nic_bridge="en0"
else
  nic_bridge="eth0"
fi
vm_path="VMs/"
vm_mem="768"
vm_mem_xp="512"
deuac_iso="deuac.iso"
tools_path="Tools/"
selenium_path="Tools/selenium_conf/"
ie_cache_reg="ie_disablecache.reg"
ie_protectedmode_reg="ie_protectedmode.reg"
log_path=""
vbox_user="${USER}"
mailto="root"
create_snapshot=False
