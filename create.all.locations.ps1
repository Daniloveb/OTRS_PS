# v2 == Не создаем корпуса - только комнаты

#=====Logger
. "$PSScriptRoot\get-logger.ps1"
$Logger = Get-Logger "$PSScriptRoot\Log.txt"

. "$PSScriptRoot\functions.location.ps1"

[string]$DatabaseName = 'Personnel2'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "SELECT[Korp]+ '-' + [Komn] Komn FROM [C2].[dbo].[Geo]"
$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
	$conn.Open()

    $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
	$cmdR = $cmd.ExecuteReader()
#====================================================================================================
#For each Record
#====================================================================================================
    while ($cmdR.Read()) 
    {
        $FullName = $cmdR['Komn']
        Write-Host ==============================================
        Write-Host "Create " $FullName
        create-location $FullName Комната
    }
    $cmdR.Close()
    $conn.Close()

