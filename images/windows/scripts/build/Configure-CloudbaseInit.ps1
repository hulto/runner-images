$progresspreference='SilentlyContinue'
iwr -MaximumRedirection 5 -OutFile CloudbaseInitSetup_x64.msi https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi

Start-Process msiexec.exe -ArgumentList '/i CloudbaseInitSetup_x64.msi /qn /norestart' -Wait

$initunattendeconfig = @"
[DEFAULT]
# What user to create and in which group(s) to be put.
username=Admin
groups=Administrators
inject_user_password=true  # Use password from the metadata (not random).
# Path to tar implementation from FreeBSD: https://www.freebsd.org/cgi/man.cgi?tar(1).
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
# Logging debugging level.
verbose=true
debug=true
# Where to store logs.
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init-unattend.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN
logging_serial_port_settings=
# Enable MTU and NTP plugins.
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
# Where are located the user supplied scripts for execution.
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
# Services that will be tested for loading until one of them succeeds.
metadata_services=cloudbaseinit.metadata.services.nocloudservice.NoCloudConfigDriveService
# What plugins to execute.
plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,
        cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
# Miscellaneous.
allow_reboot=false    # allow the service to reboot the system
stop_service_on_exit=false

[config_drive]
raw_hhd=true
types=iso
"@

Set-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf" $initunattendeconfig

$initconfig = @"
[DEFAULT]
username=Admin
groups=Administrators
inject_user_password=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init-unattend.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN
logging_serial_port_settings=
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.nocloudservice.NoCloudConfigDriveService

[config_drive]
raw_hhd=true
types=iso
"@

Set-Content "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf" $initconfig
rm CloudbaseInitSetup_x64.msi
