$progresspreference='SilentlyContinue'
iwr -MaximumRedirection 5 -OutFile virtio-win-gt-x64.msi https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/virtio-win-gt-x64.msi

Start-Process msiexec.exe -ArgumentList '/i virtio-win-gt-x64.msi /qn /norestart' -Wait

del virtio-win-gt-x64.msi
