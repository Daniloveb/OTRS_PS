[string]$Global:UserLogin = "srv_otrs"
[string]$Global:Password = "P@ssw0rd"
[string]$Global:url = "http://10.1.68.111:80/otrs/nph-genericinterface.pl/Webservice/"
[string]$Global:SoapNameSpace = "http://www.otrs.org/Connector/"
[string]$Global:SQLServerName = 'vsql2016.domain.ru'
[string]$Global:CustomerID = 'DOMAIN'
$Global:encoding = [System.Text.Encoding]::UTF8
#[string]$Global:LogPath = "C:/_CMD/log.txt"
. "$PSScriptRoot\get-logger.ps1"
$Global:Logger = Get-Logger "C:/_CMD/log.txt"