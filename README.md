modernie_selenium
=================

Manage modern.ie VBox-VMs with Selenium-Support

This script allows to delete and create virtual Windows-Machines using Images from modern.ie for automating Browser-Testing with Selenium.

As the modern.ie-Machines refuses to run more than 30-90 Days (at least for more than an hour) we remove the machines on a regular basis and recreate the original Appliance with all changes needed to run Selenium.

Prerequisites
=================

  * modern.ie VBox-Appliances
  * VirtualBox (tested with 4.3)
  * VirtualBox Extension Pack
  * Selenium-Hub
  * deuac.iso
  * IEDriverServer (for Selenium)
  * Java JRE (for Selenium)
  * Selenium Standalone Server
  * Optional: phpVirtualBox
   
What it does
=================

  * Import modern.ie Appliances to VirtualBox
  * Configure VM Network-Settings
  * Configure VM RDP-Port-Setting (VRDE)
  * Configure VM Clipboard behaviour
  * Disable UAC
  * Disable Windows-Firewall
  * Rename the VM (Hostname)
  * Configures IE Protected-Mode to work with Selenium
  * Disables IE Cache
  * Install Java
  * Install Firefox
  * Install Chrome
  * Install Selenium
  * Reports via E-Mail

What it not does
=================

  * Download modern.ie Appliances
  * Set up VirtualBox (if you use SaltStack check out: https://gist.github.com/gpkvt/b276223ad5c923023aaa)
  * Set up phpVirtualBox (again, if you use SaltStack: https://gist.github.com/gpkvt/a8785032c0aa3d920ab9)
   
Getting started
=================

  * Download the Appliance(s) you want to use from http://www.modern.ie/ and put the extracted OVA-Files on your Server. 
  * Get the Windows Java (JRE) Installer and Selenium Server Standalone (JAR) and put them beside the OVA-Files (or somewhere else).
  * Get deuac.iso (https://github.com/tka/SeleniumBox/blob/master/deuac.iso)
  * Get IEDriverServer.exe (https://code.google.com/p/selenium/wiki/InternetExplorerDriver)  and put it in ```Tools/selenium_conf/```
  * Clone this repository
  * Edit the Selenium Config-Files (```./Tools/Selenium_conf/*/config.json```)
  * Edit the Config-Section in mkvm.sh so it fits your needs (see below for details)
  * ```chmod +x mkvm.sh```
  * Run ```mkvm.sh /path/to/your/appliance/foobar.ova```

Configure
================

By default the Script assumes that your VirtualBox-Machines are placed in ```/srv/VMs/``` and that the script is run by the User ```vbox```. All supplemental files should be placed in ```/opt/Tools/``` but you can configure different paths.

To do so simply edit ```mkvm.sh```:

```
java_exe="jre-7u55-windows-i586.exe"
```

Filename of your Java-Installer.

```
selenium_jar="selenium-server-standalone-2.41.0.jar"
```

Filename of your Selenium-Server.

```
nic_bridge="eth2"
```

Name of your Network-Interface to use as bridge for your VM.

```
vm_path="/srv/VMs/"
```

Path where to put your VMs.

```
vm_mem="768"
```

Amount of memory (RAM) for Windows Vista, 7 and 8.x VMs in MB.

```
vm_mem_xp="512"
```

Amount of memory (RAM) for Windows XP VMs in MB.

```
deuac_iso="/opt/Tools/deuac.iso"
```

Path and filename for deuac.iso (a bootable CD-Image to disable UAC so we can install Java without Problems).

```
tools_path="/opt/Tools/"
```

Path to ```java_exe```, ```firefox_exe``` and ```chrome_exe``` (Location of Installers on VM-Host).

```
selenium_path="/opt/Tools/selenium_conf/"
```

Path to your Selenium-Config-Files. It's important that you keep the folder structure below this point, otherwise the config will not be copied to the VMs (or the wrong Config goes to the wrong Machines).

```
ie_cache_reg="/opt/Tools/ie_disablecache.reg"
```

Path and filename to ```ie_disablecache.reg``` (Disables Internet Explorer Cache).

```
ie_protectedmode_reg="/opt/Tools/ie_protectedmode.reg"
```

Path and filename to ```ie_protectedmode.reg``` (Enables Protected Mode for all IE Security Zones). 

```
log_path="/home/vbox/"
```

Path to the (temporary) Logfile.

```
vbox_user="vbox"
```

Username of VirtualBox-User.

```
mailto="root@example.com"
```

E-Mail-Adress to send logfile to.

```
create_snapshot=False
```

If ```True``` a snapshot will be created after all changes have been made.

Usage
=====

To import the IE6-WinXP Appliance simply run:

```
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/xp/ie6/IE6\ -\ WinXP.ova"
```

If you already have an IE6-WinXP-Instance - and want to recreate it - run:

```
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/xp/ie6/IE6\ -\ WinXP.ova" --delete "IE6 - WinXP"
```

We recommend to use a CronJob to recreate the VMs on a regular basis. See ```mkvm_cronjob```. To avoid too much load on the Host we use a Wrapper-Script ```mkvm_cron.sh``` so that only one Appliance gets imported after another.

Known Problems
==============

XP-Machines doesn't set their new hostname automatically. You can use ```C:\Temp\rename.bat``` to set the correct name. Restart the VM afterwards. This is only needed if you run more than one instance of the same Appliance.

Acknowledgements
================

  * deuac.iso comes from https://github.com/tka/SeleniumBox
  * Inspired by https://github.com/xdissent/ievms
  * Thanks to https://github.com/dsuckau for the Selenium-Config Part
