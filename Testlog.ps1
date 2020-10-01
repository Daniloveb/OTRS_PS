requires -version 3
$ErrorActionPreference = 'Stop' 
# создание объекта логгера, код которого смотрите ниже, 
# инкапсулирующего знание о пути к логу и формату записи 
$Logger = Get-Logger "$PSScriptRoot\Log.txt" 
# глобальная ловушка ошибок
trap { 
	$Logger.AddErrorRecord( $_ ) 
	exit 1 
} 
# счётчик попыток подключения 
$count = 1;
while ( $true ) {
	 try { 
	# попытка подключения 
	$StorageServers = @( Get-ADGroupMember -Identity StorageServers | Select-Object -Expand Name ) 
	} catch [System.Management.Automation.CommandNotFoundException] {
		# выбрасываемое наружу исключение в силу того, что нет смысла продолжать выполнение без установки модуля 
		throw "Командлет Get-ADGroupMember недоступен, требуется добавить фичу Active Directory module for PowerShell; $( $_.Exception.Message )"
		 } catch [System.TimeoutException] { 
		# переход к следующей итерации цикла в случае если количество попыток не превышено
		if ( $count -le 3 ) { $count++; Start-Sleep -S 10; continue }
		# остановка выполнения и выбрасывание исключения наружу в силу невозможности получения необходимых данных 
		throw "Подключение к серверу небыло установленно из-за ошибки таймаута соединения, было произведено $count попыток; $( $_.Exception.Message )"
		}
		# выход из цикла в случае отсутствия исключительных ситуаций
		break 
	}


function Get-Logger {
	[CmdletBinding()]
	param (
		[Parameter( Mandatory = $true )] 
		[string] $LogPath,
		[string] $TimeFormat = 'yyyy-MM-dd HH:mm:ss' 
	)

	$LogsDir = [System.IO.Path]::GetDirectoryName( $LogPath )
	New-Item $LogsDir -ItemType Directory -Force | Out-Null
	New-Item $LogPath -ItemType File -Force | Out-Null

	$Logger = [PSCustomObject]@{ 
		LogPath = $LogPath
		TimeFormat = $TimeFormat
	}
	Add-Member -InputObject $Logger -MemberType ScriptMethod AddErrorRecord -Value { 
		param(
			[Parameter( Mandatory = $true )]
			[string]$String
		)
		"$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' ) [Error] $String" | Out-File $this.LogPath -Append
	}
	return $Logger
}
