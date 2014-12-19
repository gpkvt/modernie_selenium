all: fetch fetch_vms

fetch: Tools/selenium_conf/selenium-server-standalone.jar Tools/deuac.iso Tools/selenium_conf/IEDriverServer.exe

fetch_vms: VMs/IE11\ -\ Win7.ova VMs/IE8\ -\ Win7.ova

VMs/IE11\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE11-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE11_Win7/Mac/IE11.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE11.Win7.For.MacVirtualBox.part1.sfx
	./IE11.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE11.Win7.For.MacVirtualBox.part1.sfx IE11.Win7.For.MacVirtualBox.part2.rar IE11.Win7.For.MacVirtualBox.part3.rar IE11.Win7.For.MacVirtualBox.part4.rar

VMs/IE8\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE8-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE8_Win7/Mac/IE8.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE8.Win7.For.MacVirtualBox.part1.sfx
	./IE8.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE8.Win7.For.MacVirtualBox.part1.sfx IE8.Win7.For.MacVirtualBox.part2.rar IE8.Win7.For.MacVirtualBox.part3.rar IE8.Win7.For.MacVirtualBox.part4.rar

Tools/selenium_conf/selenium-server-standalone.jar:
	curl -o Tools/selenium_conf/selenium-server-standalone.jar -L http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar

Tools/deuac.iso:
	curl -o Tools/deuac.iso -L https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true

Tools/selenium_conf/IEDriverServer.exe:
	curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip
	curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_x64_2.44.0.zip
	cd Tools/selenium_conf && unzip IEDriverServer.zip

