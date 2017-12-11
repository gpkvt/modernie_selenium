all: fetch fetch_vms

fetch: selenium-server deuac IEDriver

fetch_vms: IE11-Win7 IE10-Win7 IE9-Win7 IE8-Win7

IE11-Win7:
	curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE11/Windows/IE11.Win7.For.Windows.VirtualBox.zip"
	unzip IE11.Win7.For.Windows.VirtualBox.zip
	mkdir VMs || true
	mv IE11\ -\ Win7.ova VMs
	rm IE11.Win7.For.Windows.VirtualBox.zip


IE10-Win7:
	curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE10/Windows/IE10.Win7.For.Windows.VirtualBox.zip"
	unzip IE10.Win7.For.Windows.VirtualBox.zip
	mkdir VMs || true
	mv IE10\ -\ Win7.ova VMs
	rm IE10.Win7.For.Windows.VirtualBox.zip

IE9-Win7:
	curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE9/Windows/IE9.Win7.For.Windows.VirtualBox.zip"
	unzip IE9.Win7.For.Windows.VirtualBox.zip
	mkdir VMs || true
	mv IE9\ -\ Win7.ova VMs
	rm IE9.Win7.For.Windows.VirtualBox.zip

IE8-Win7:
	curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE8/Windows/IE8.Win7.For.Windows.VirtualBox.zip"
	unzip IE8.Win7.For.Windows.VirtualBox.zip
	mkdir VMs || true
	mv IE8\ -\ Win7.ova VMs
	rm IE8.Win7.For.Windows.VirtualBox.zip

selenium-server:
	curl -o Tools/selenium_conf/selenium-server-standalone.jar -L http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar

deuac:
	curl -o Tools/deuac.iso -L https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true

IEDriver:
	curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip
	#curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_x64_2.44.0.zip
	cd Tools/selenium_conf && unzip IEDriverServer.zip

# Not using this as we are using vm only for IE
chromedriver:
	curl -o Tools/selenium_conf/chromedriver.zip -L http://chromedriver.storage.googleapis.com/2.15/chromedriver_win32.zip
	cd Tools/selenium_conf && unzip chromedriver.zip

# Commenting command line jre download as this is broken, oracle has include some sort of hash in download url, need to fix this
#Tools/jre-windows-i586.exe:
#	curl -j -o Tools/jre-windows-i586.exe -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/jre-8u151-windows-i586.exe

# Not using this as we are using vm only for IE
firefox:
	curl -o Tools/firefox.exe -L "https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"

# Not using this as we are using vm only for IE
chrome:
 	curl -o Tools/chrome.exe -L "https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"
