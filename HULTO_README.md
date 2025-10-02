# Setup dev environment
```bash
# Install Powershell
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# Install az cli
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
cat << EOF | sudo tee /etc/apt/sources.list.d/azure-cli.sources
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg
EOF

sudo apt-get update
sudo apt-get install azure-cli

# Install packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install packer

az login

az ad sp create-for-rbac --role Contributor --scopes /subscriptions/2ff36a90-fb00-4e91-bb2c-831390abfb40 --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"


pwsh
```

Create resource group - `runner-build`
Create network - `runner-build`

# Build images in azure
```powershell
az sig create --resource-group runner-build --gallery-name myGallery

az sig image-definition create `
   --resource-group runner-build `
   --hyper-v-generation V1 `
   --gallery-name myGallery `
   --gallery-image-definition ubuntu24runnerbuild `
   --publisher me `
   --offer test `
   --sku build `
   --os-type Linux `
   --os-state Generalized

PS /workspace/runner-images> $Env:GALLERY_NAME="myGallery"
PS /workspace/runner-images> $Env:GALLERY_RG_NAME="runner-build"
PS /workspace/runner-images> $Env:GALLERY_IMAGE_VERSION="1.0.1"
PS /workspace/runner-images> $Env:GALLERY_IMAGE_NAME="ubuntu24runnerbuild"
PS /workspace/runner-images> Import-Module ./helpers/GenerateResourcesAndImage.ps1
PS /workspace/runner-images> GenerateResourcesAndImage `
        -SubscriptionId "2ff36a90-fb00-4e91-bb2c-831390abfb40" `
        -ResourceGroupName "runner-build" `
        -ImageType "Ubuntu2404" `
        -AzureLocation "East US" `
        -ImageGenerationRepositoryRoot "/workspace/runner-images" `
        -RestrictToAgentIpAddress ubuntu24runnerbuild3


az sig image-definition create `
   --resource-group runner-build `
   --hyper-v-generation V1 `
   --gallery-name myGallery `
   --gallery-image-definition win25runnerbuild `
   --publisher me `
   --offer test `
   --sku winbuild `
   --os-type Windows `
   --os-state Generalized

PS /workspace/runner-images> $Env:GALLERY_NAME="myGallery"
PS /workspace/runner-images> $Env:GALLERY_RG_NAME="runner-build"
PS /workspace/runner-images> $Env:GALLERY_IMAGE_VERSION="1.0.1"
PS /workspace/runner-images> $Env:GALLERY_IMAGE_NAME="win25runnerbuild"
PS /workspace/runner-images> Import-Module ./helpers/GenerateResourcesAndImage.ps1
PS /workspace/runner-images> GenerateResourcesAndImage `
        -SubscriptionId "2ff36a90-fb00-4e91-bb2c-831390abfb40" `
        -ResourceGroupName "runner-build" `
        -ImageType "Windows2025" `
        -AzureLocation "East US" `
        -ImageGenerationRepositoryRoot "/workspace/runner-images" `
        -RestrictToAgentIpAddress win25runnerbuild


az sig image-version list `
   --resource-group "runner-build" `
   --gallery-name 'myGallery' `
   --gallery-image-definition "ubuntu24runnerbuild" `
   -o table

az disk create --resource-group "runner-build" --location "East US" --name exportDisk1.0.2 --gallery-image-reference "/subscriptions/2ff36a90-fb00-4e91-bb2c-831390abfb40/resourceGroups/runner-build/providers/Microsoft.Compute/galleries/myGallery/images/ubuntu24runnerbuild/versions/1.0.2" 

az disk create --resource-group "runner-build" --location "East US" --name exportDiskwin1.0.0 --gallery-image-reference "/subscriptions/2ff36a90-fb00-4e91-bb2c-831390abfb40/resourceGroups/runner-build/providers/Microsoft.Compute/galleries/myGallery/images/win25runnerbuild/versions/1.0.0" 


# TODO:
# - Switch windows to DHCP - seems to work when network is set to e1000
# - OS boots when Disk set to SATA not virtio
# - Resolve Administrator and locale setup - Probably can ignore
# - Fix post setup ^ grey screen - Probably can ignore

# - Install cloudbase-init
# - Install qemu-guestagent
# "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf" --debug --noreset_service_password
```

# Export

Navigate to the newly created disk.
Click export disk.
You may need to increase the link timeout.
Click generate link.
