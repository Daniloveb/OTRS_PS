# v1 Синхронизируем выборку измененений в SCS из С2 за последний период
# задаем период $Days
param (
    [Parameter( Mandatory = $true )] [int] $Days) #число)

#Set-StrictMode -Version Latest
#$ErrorActionPreference='Stop'
Get-Date | Write-Host 

#=====Logger
#. "$PSScriptRoot\get-logger.ps1"
#$Logger = Get-Logger "$PSScriptRoot\Log.txt"

. "$PSScriptRoot\functions.location.ps1"
. "$PSScriptRoot\functions.ci.ps1"
. "$PSScriptRoot\functions.link.ps1"

[string]$DatabaseName = 'C2'
[string]$SQLServerName = 'vsql2016.novator.ru'

[string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
[string]$SQLCommand = "
Select IDs.LogTime, IDs.[Value], Macs.Name from
(SELECT LogTime, OldValue Value
FROM [C2].[dbo].[Log]
where 
		TableName = '[dbo].[SCS]' and LogTime >= DATEADD(DAY,-$Days, GETDATE()) and (ColumnName = 'ID_vMACs') 
	and OldValue is not null 
	and OldValue <> cast('00000000-0000-0000-0000-000000000000' as uniqueidentifier) 

UNION ALL

SELECT LogTime, NewValue Value
FROM [C2].[dbo].[Log]
where 
		TableName = '[dbo].[SCS]' and LogTime >= DATEADD(DAY,-10, GETDATE()) and (ColumnName = 'ID_vMACs') 
	and NewValue is not null 
    and NewValue <> cast('00000000-0000-0000-0000-000000000000' as uniqueidentifier) ) IDs
    
left join
	(SELECT [ID]
      ,[Name]
      ,[Type]
  FROM [C2].[dbo].[v_MACs_forLookup]) Macs
  on IDs.Value = Macs.ID"

$conn = New-Object System.Data.SqlClient.SqlConnection($connString)
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
$cmdR = $cmd.ExecuteReader()
while ($cmdR.Read()) { 
    Write-Host ==============================================
$NameSQL = $cmdR['Name']
if ($NameSQL.Contains("PRN")) {
        $Name = $NameSQL.Substring(0,$NameSQL.Indexof(':'))
}
else {
        $Name = $NameSQL.Substring(0,$NameSQL.Indexof(':'))
        
    }
    Write-host $Name

}