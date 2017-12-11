modernie_selenium
=================

Manage modern.ie VirtualBox-Appliances with Selenium-Support

This script allows to delete and create virtual Windows-Machines using Images from http://www.modern.ie for automating Browser-Testing with Selenium.

As the modern.ie-Machines refuses to run more than 30-90 Days (at least for more than an hour) we remove the machines on a regular basis and recreate the original Appliance with all changes needed to run Selenium.


Prerequisites
=================

  * VirtualBox (tested with 5.0.30)
  * VirtualBox Extension Pack
  * Selenium-Hub
  

What it does
=================

  * Import modern.ie VM images to VirtualBox
  * Configure VM Network-Settings
  * Configure VM RDP-Port-Setting (VRDE)
  * Configure VM Clipboard behaviour
  * Disable UAC
  * Disable Windows-Firewall
  * Rename the VM (Hostname)
  * Configures IE Protected-Mode to work with Selenium
  * Disables IE Cache
  * Install Java
  * Install Selenium
 

What it doesn't do
==================

  * Set up VirtualBox

Getting started
===============

  * Run make all
  * Run ```mkvm.sh /path/to/your/appliance/foobar.ova```.

Fetching the Appliances
=======================

Get all VM images using this command:

```
make fetch_vms
```

Configure
=========

Adjust ```config.sh``` to your needs. See below for details.

If you use the Makefile to get the binary files then you shouldn't have to alter the config script.

By default the Script assumes that your VirtualBox-Machines are placed in ```VMs/``` and that the script is run by the User the script is run as. All supplemental files should be placed in ```Tools/``` but you can configure different paths.

To do so simply edit ```config.sh```:

```
java_exe="jre-windows-i586.exe"
```

Filename of your Java-Installer.

```
selenium_jar="selenium-server-standalone.jar"
```

Filename of your Selenium-Server.

```
nic_bridge="eth0"
```

Name of your Network-Interface to use as bridge for your VM.

```
vm_path="VMs/"
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
deuac_iso="Tools/deuac.iso"
```

Path and filename for deuac.iso (a bootable CD-Image to disable UAC so we can install Java without Problems).

```
tools_path="Tools/"
```

Path to ```java_exe```, ```firefox_exe``` and ```chrome_exe``` (Location of Installers on VM-Host).

```
selenium_path="Tools/selenium_conf/"
```

Path to your Selenium-Config-Files. It's important that you keep the folder structure below this point, otherwise the config will not be copied to the VMs (or the wrong Config goes to the wrong Machines).

```
ie_cache_reg="Tools/ie_disablecache.reg"
```

Path and filename to ```ie_disablecache.reg``` (Disables Internet Explorer Cache).

```
ie_protectedmode_reg="Tools/ie_protectedmode.reg"
```

Path and filename to ```ie_protectedmode.reg``` (Enables Protected Mode for all IE Security Zones).

```
log_path=""
```

Path to the (temporary) Logfile.

```
vbox_user="${USER}"
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

Selenium Config / Hub Hostname
==============================

The supplied Selenium-Node-Configs (see ```Tools/selenium_conf/*/config.json```) assumes the Hostname ```hubhost``` for your Selenium-Hub. So you should set up your hostfiles/DNS-Services accordingly or change ```"hubHost": "hubhost"```, in all needed ```config.json``` files.

Check out ```updateip.sh``` if you want to modify the Hostfiles (change ```nic_bridge``` if needed; be aware that the VBox-Host is expected to be your Selenium-Hub as well).

Usage
=====

Run below command:

```
make fetch
```
Get specific VM image[Check options in make file]:

```
make VMs/IE11\ -\ Win7.ova
```

To import the IE11-Win7 Appliance simply run:

```
mkvm.sh VMs/IE11\ -\ Win7.ova
```

If you already have an IE11-Win7-Instance - and want to recreate it - run:

```
mkvm.sh VMs/IE11\ -\ Win7.ova --delete "IE11 - Win7"
```


TODO
==============

* Network Confguration
* Jre installation link broken as Oracle has included has in the url[Fix: JRE exe is on Tools directory]
* Windows silent activation

