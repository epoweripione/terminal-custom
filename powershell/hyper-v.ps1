#Requires -RunAsAdministrator

# https://docs.microsoft.com/zh-cn/virtualization/hyper-v-on-windows/about/
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V


# Get-Command -Module hyper-v | Out-GridView

# Get-VM | Where-Object {$_.State -eq 'Running'}
# Get-VM | Where-Object {$_.State -eq 'Off'}

# Start-VM -Name <virtual machine name>
# Get-VM | Where-Object {$_.State -eq 'Off'} | Start-VM
# Get-VM | Where-Object {$_.State -eq 'Running'} | Stop-VM

# Get-VM -Name <VM Name> | Checkpoint-VM -SnapshotName <name for snapshot>


# https://docs.microsoft.com/powershell/module/hyper-v/new-vm?view=win10-ps
$VMName = "Win7"
# Mem: 2GB, Disk: 50GB
$VM = @{
    Name = $VMName
    MemoryStartupBytes = 2*1024*1024*1024
    Generation = 2
    NewVHDPath = "C:\HyperVM\$VMName\$VMName.vhdx"
    NewVHDSizeBytes = 50*1024*1024*1024
    BootDevice = "VHD"
    Path = "C:\HyperVM\$VMName"
    SwitchName = (Get-VMSwitch).Name
}

New-VM @VM


# https://docs.microsoft.com/zh-cn/virtualization/hyper-v-on-windows/quick-start/connect-to-network
# $net = Get-NetAdapter -Name 'Ethernet'
$net = Get-NetAdapter `
    | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Virtual*"}
New-VMSwitch -Name "External VM Switch" -AllowManagementOS $True -NetAdapterName $net.Name
