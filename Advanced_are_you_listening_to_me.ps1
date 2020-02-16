<#
.Synopsis
   Display listening and established connections on a computer’s primary IPv4 address
.EXAMPLE
   C:\PS> Get-SkyNetTcpConnection -ComputerName DC01,DC02
   This command gets the listening and established connections on remote computers DC01 and DC02 primary IPv4 addressess.
.EXAMPLE
   C:\PS> Get-SkyNetTcpConnection
   This command gets the listening and established connections on your local computers primary IPv4 address.
.EXAMPLE
   C:\PS> Get-SkyNetTcpConnection -ResolveHostname
   This command gets the listening and established connections on your local computers primary IPv4 address and attempts to resolve IP addresses via DNS.
#>
# Local Admin needed for Get-Process -IncludeUserName
#Requires -RunAsAdministrator

function Get-SkyNetTcpConnection {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        $ComputerName,

        [Parameter()]
        [switch]$ResolveHostname
    )
    begin {}
    process {
        if($ComputerName){
                ForEach ($Computer in $ComputerName){
                    Write-Verbose "Checking network connections on computer name: $Computer"
                    Invoke-Command -ComputerName $Computer -ScriptBlock{
                        $RemoteConnections = Get-NetTcpConnection | Select-Object PSComputername,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess,CreationTime,@{name='ConnectionAge';expression={$(Get-Date) - $_.CreationTime}} | Where-Object {$_.LocalAddress -Match $(Get-NetIPAddress -InterfaceAlias Ethernet0) -and $_.State -match 'Listen|Established' -and $_.LocalPort -notmatch '5985'}
                        $RemoteConnections | ForEach-Object{
                            # get associated username for each process associated with net connection
                            $OwningProcess = Get-Process -IncludeUserName | Select-Object ProcessName,ID,Path,Username | Where-Object Id -Match $_.OwningProcess
                            # set common remoteportnames via switch
                            $RemotePortName = ""
                            switch ($_.RemotePort) {
                                5985{$RemotePortName = 'WINRM'}
                                993{$RemotePortName = 'IMAP SSL'}
                                443{$RemotePortName = 'HTTPS'}
                                389{$RemotePortName = 'LDAP'}
                                143{$RemotePortName = 'IMAP'}
                                139{$RemotePortName = 'NETBIOS'}
                                80{$RemotePortName = 'HTTP'}
                                53{$RemotePortName = 'DNS'}
                                25{$RemotePortName = 'SMTP'}
                                23{$RemotePortName = 'TELNET'}
                                20{$RemotePortName = 'FTP'}
                                22{$RemotePortName = 'SSH/SFTP'}
                            }
                            # check $resolvehostname switch and resolve if true
                            $RemoteAddress = If($using:ResolveHostname){
                                Try{
                                    Resolve-DnsName $_.RemoteAddress -ErrorAction Stop | Select-Object -ExpandProperty NameHost
                                }
                                Catch{
                                    Write-Warning "Cannot resolve hostname for $($_.RemoteAddress)"
                                }
                            }
                            Else{
                                $_.RemoteAddress
                            }
                            [pscustomobject]@{
                                LocalAddress = $_.LocalAddress
                                LocalPort = $_.LocalPort
                                RemoteAddress = $RemoteAddress
                                RemotePort = $_.RemotePort
                                RemotePortAlias = $RemotePortName
                                State = $_.State
                                OwningProcess = $OwningProcess.ProcessName
                                UserOwningProcess = $OwningProcess.UserName
                                OwningProcessPath = $OwningProcess.Path
                                CreationTime = $_.CreationTime
                                ConnectionAge = $_.ConnectionAge
                            }
                        }
                    }
                }
            }
            else{
                Write-Verbose "Checking network connections on computer name: $ENV:COMPUTERNAME"
                $RemoteConnections = Get-NetTcpConnection | Select-Object PSComputername,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess,CreationTime,@{name='ConnectionAge';expression={$(Get-Date) - $_.CreationTime}} | Where-Object {$_.LocalAddress -Match $(Get-NetIPAddress -InterfaceAlias Ethernet0) -and $_.State -match 'Listen|Established'}
                $RemoteConnections | ForEach-Object{
                    # get associated username for each process associated with net connection
                    $OwningProcess = Get-Process -IncludeUserName | Select-Object ProcessName,ID,Path,Username | Where-Object Id -Match $_.OwningProcess
                    # set common remoteportnames via switch
                    $RemotePortName = ""
                    switch ($_.RemotePort) {
                        5985{$RemotePortName = 'WINRM'}                        
                        993{$RemotePortName = 'IMAP SSL'}
                        445{$RemotePortName = 'microsoft-ds'}
                        443{$RemotePortName = 'HTTPS'}
                        389{$RemotePortName = 'LDAP'}
                        143{$RemotePortName = 'IMAP'}
                        139{$RemotePortName = 'NETBIOS'}
                        80{$RemotePortName = 'HTTP'}
                        53{$RemotePortName = 'DNS'}
                        25{$RemotePortName = 'SMTP'}
                        23{$RemotePortName = 'TELNET'}
                        20{$RemotePortName = 'FTP'}
                        22{$RemotePortName = 'SSH/SFTP'}
                    }
                    # check $resolvehostname switch and resolve if true
                    $RemoteAddress = If($ResolveHostname){
                        Try{
                            Resolve-DnsName $_.RemoteAddress -ErrorAction Stop | Select-Object -ExpandProperty NameHost
                        }
                        Catch{
                            Write-Warning "Cannot resolve hostname for $($_.RemoteAddress)"
                        }
                    }
                    Else{
                        $_.RemoteAddress
                    }
                    [pscustomobject]@{
                        LocalAddress = $_.LocalAddress
                        LocalPort = $_.LocalPort
                        RemoteAddress = $RemoteAddress
                        RemotePort = $_.RemotePort
                        RemotePortAlias = $RemotePortName
                        State = $_.State
                        OwningProcess = $OwningProcess.ProcessName
                        UserOwningProcess = $OwningProcess.UserName
                        OwningProcessPath = $OwningProcess.Path
                        CreationTime = $_.CreationTime
                        ConnectionAge = $_.ConnectionAge
                        PSComputername = $ENV:COMPUTERNAME
                    }
                }
            }
        }
    end {}
}