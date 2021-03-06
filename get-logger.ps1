﻿

function Get-Logger {
	[CmdletBinding()]
	param ([Parameter( Mandatory = $true )] [string] $LogPath)
	[string] $TimeFormat = 'yyyy-MM-dd HH:mm:ss' 
	$LogsDir = [System.IO.Path]::GetDirectoryName( $LogPath )
	#New-Item $LogsDir -ItemType Directory -Force | Out-Null
	#New-Item $LogPath -ItemType File -Force | Out-Null


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
	Add-Member -InputObject $Logger -MemberType ScriptMethod AddInfoRecord -Value { 
		param(
			[Parameter( Mandatory = $true )]
			[string]$String
		)
		"$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' ) [Info] $String" | Out-File $this.LogPath -Append
		"$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' ) [Info] $String" | Write-Host
	}
	Add-Member -InputObject $Logger -MemberType ScriptMethod AddWarningRecord -Value { 
		param(
			[Parameter( Mandatory = $true )]
			[string]$String
		)
		"$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' ) [Warning] $String" | Out-File $this.LogPath -Append
	}
	return $Logger
}