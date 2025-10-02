$progresspreference='SilentlyContinue'
iwr -MaximumRedirection 5 -OutFile virtio-win-guest-tools.exe https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/virtio-win-guest-tools.exe

start-process .\virtio-win-guest-tools.exe -ArgumentList "/install /passive" -Wait

del virtio-win-guest-tools.exe
