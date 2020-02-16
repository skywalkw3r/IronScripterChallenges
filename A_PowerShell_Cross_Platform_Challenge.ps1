function Get-Uname {
    [CmdletBinding()]
    Param(
        [switch]$All
    )
    if($All){
        [PSCustomObject]@{
            KernelName = "$(uname --kernel-name)"
            NodeName = "$(uname --nodename)"
            KernelRelease = "$(uname --kernel-release)"
            KernelVersion = "$(uname --kernel-version)"
            Machine = "$(uname --machine)"
            Processor = "$(uname --processor)"
            HardwarePlatform = "$(uname --hardware-platform)"
            OperatingSystem = "$(uname --operating-system)"
        }    
    }
    else {
        [PSCustomObject]@{
            KernelName = "$(uname)"
        }
    }
}