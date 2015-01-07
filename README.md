modernie_selenium
=================

Manage modern.ie VirtualBox-Appliances with Selenium-Support

This script allows to delete and create virtual Windows-Machines using Images from http://www.modern.ie for automating Browser-Testing with Selenium.

As the modern.ie-Machines refuses to run more than 30-90 Days (at least for more than an hour) we remove the machines on a regular basis and recreate the original Appliance with all changes needed to run Selenium.

Use it with your favored test runner (maybe [Karma](http://karma-runner.github.io/) or [Nightwatch.js](http://nightwatchjs.org)) to automate JavaScript tests in real browsers on your own Selenium Grid. Other WebDriver language bindings (Python, Java) should work as well.

Prerequisites
=================

  * modern.ie VBox-Appliances
  * VirtualBox (tested with 4.3)
  * VirtualBox Extension Pack
  * Selenium-Hub
  * deuac.iso
  * IEDriverServer (for Selenium)
  * chromedriver (for Selenium)
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

What it doesn't do
==================

  * Download modern.ie Appliances
  * Set up VirtualBox

Getting started
===============

  * Clone this repository.
  * Download the Appliance(s) you want to use from http://www.modern.ie/ and put the extracted OVA-Files on your Server. You can use the Makefile (see below)
  * Get the Windows Java (JRE) Installer and Selenium Server Standalone (JAR) and put them beside the OVA-Files (or somewhere else).
  * Get deuac.iso (https://github.com/tka/SeleniumBox/blob/master/deuac.iso).
  * Get IEDriverServer.exe (https://code.google.com/p/selenium/wiki/InternetExplorerDriver) and put it in ```./Tools/selenium_conf/```.
  * Get chromedriver.exe (https://code.google.com/p/selenium/wiki/ChromeDriver) and put it in ```./Tools/selenium_conf/```.
  * Get Chrome and Firefox, place both in ```./Tools/```.
  * Edit the Selenium Config-Files (```./Tools/Selenium_conf/*/config.json```).
  * Edit the Config-Section in mkvm.sh so it fits your needs (see below for details).
  * Run ```mkvm.sh /path/to/your/appliance/foobar.ova```.

Fetching the Appliances
=======================

You can get a lot of the VMs (currently IE8-11 on Windows 7) using this command:

```
make fetch_vms
```

Configure
=========

I've changed this from the original repository so that it uses a separate config script so that you can keep a local config script and not have to hack the main file.

So look in ```config.sh```

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

Usage
=====

To import the IE6-WinXP Appliance simply run:

```
mkvm.sh VMs/IE6\ -\ WinXP.ova
```

If you already have an IE6-WinXP-Instance - and want to recreate it - run:

```
mkvm.sh VMs/IE6\ -\ WinXP.ova --delete "IE6 - WinXP"
```

We recommend to use a CronJob to recreate the VMs on a regular basis. See ```mkvm_cronjob```. To avoid too much load on the Host we use a Wrapper-Script ```mkvm_cron.sh``` so that only one Appliance gets imported after another.

Known Problems
==============

XP-Machines doesn't set their new hostname automatically. You can use ```C:\Temp\rename.bat``` to set the correct name. Restart the VM afterwards. This is only needed if you run more than one instance of the same Appliance.

In the Spotlight
================

Thanks a lot for mentioning modernie_selenium!

  * Automated Testing by Ben Emmons<br>
    http://itsummit.arizona.edu/sites/default/files/2014/emmons-ben-automated-testing-final.pdf
  * Testen von Rich-Web-UI (German) by Mark Michaelis<br>
    http://de.slideshare.net/MarkMichaelis2/sokahh-testing

Acknowledgements
================

  * deuac.iso comes from https://github.com/tka/SeleniumBox
  * Inspired by https://github.com/xdissent/ievms
  * http://modern.ie is a Service offered by Microsoft, so thanks for that.
  * Thanks to https://github.com/dsuckau for the Selenium-Config Part
  * Thanks to [@tobyontour](https://github.com/tobyontour) for [pull request #8](https://github.com/conceptsandtraining/modernie_selenium/pull/8)
