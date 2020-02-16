function Get-Fahrenheit {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,
        Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^(\d*\.)?\d+$')]
        [decimal]$CelsiusTemp
    )
    [PSCustomObject]@{
        Fahrenheit = "$(($CelsiusTemp*1.8)+32)"
        Celsius = "$CelsiusTemp"
    }
}
 function Get-Celsius {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,
        Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^(\d*\.)?\d+$')]
        [decimal]$FahrenheitTemp
    )
    [PSCustomObject]@{
        Celsius = "$(($FahrenheitTemp-32)/1.8)"
        Fahrenheit = "$FahrenheitTemp"
    }
}