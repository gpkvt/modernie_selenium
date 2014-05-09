#!/bin/bash

su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/xp/ie6/IE6\ -\ WinXP.ova --delete 'IE6 - WinXP'"
sleep 30
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/xp/ie8/IE8\ -\ WinXP.ova --delete 'IE8 - WinXP'"
sleep 30

su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win7/ie8/IE8\ -\ Win7.ova --delete 'IE8 - Win7'"
sleep 30
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win7/ie9/IE9\ -\ Win7.ova --delete 'IE9 - Win7'"
sleep 30
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win7/ie10/IE10\ -\ Win7.ova --delete 'IE10 - Win7'"
sleep 30
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win7/ie11/IE11\ -\ Win7.ova --delete 'IE11 - Win7'"
sleep 30

su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/vista/ie7/IE7\ -\ Vista.ova --delete 'IE7 - Vista Clone'"
sleep 30

su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win8/ie10/IE10\ -\ Win8.ova --delete 'IE10 - Win8'"
sleep 30
su vbox --shell=/bin/bash -c "/opt/mkvm.sh /opt/Appliances/win8/ie11/IE11\ -\ Win8.ova --delete 'IE11 - Win8.1'"
sleep 30
