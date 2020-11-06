   function get-domainuser-login{
            [CmdletBinding()]
	param (
       [Parameter( Mandatory = $true )] [string] $ID_Personel
    )
            #$ID_Personel = '0CA4BF12-67F4-4058-B9DD-74BCD354D9FF'
            $u = Get-ADUser -f{extensionAttribute7 -eq $ID_Personel}
            if ([string]::IsNullOrEmpty($u) -eq $false){
                return $u.SamAccountName
            }
            else {
                return "srv_otrs"
            }
    }

   function synch-tickets{

      . "$PSScriptRoot\functions.ticket.ps1"
      . "$PSScriptRoot\functions.link.ps1"
      . "$PSScriptRoot\functions.share.ps1"
      . "$PSScriptRoot\Set-GlobalVars.ps1"
        
    #Перебираем тикеты и ищем в title номер арма типа 1234@
    #Первый и последний ID тикетов задаем руками
    [int32]$start = 70368 #1415
    [int32]$end = 89863 #89863
    
    foreach ($id in $start..$end)
    {   
        $title=(get-ticket $id)['Title']
        write-host $title
        $index = $title.IndexOf("@")
        if ($index -ne -1){
            [int]$nk = $title.substring(($index-4),4)
            write-host ===================
            Write-Host nk $nk
            $CIId = get-ConfigItemId Computer $nk
            create-link ITSMConfigItem $CIId Ticket $id RelevantTo Valid 4
        }
    }
   }

   function synch-16-tickets{

    . "$PSScriptRoot\functions.ticket.ps1"
    . "$PSScriptRoot\functions.link.ps1"
    . "$PSScriptRoot\functions.share.ps1"
    . "$PSScriptRoot\Set-GlobalVars.ps1"
      
    Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
    $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

    [string]$DatabaseName = 'LaRevue2'
    [string]$SQLServerName = 'vsql2016.novator.ru'

    [string]$connString = 'Server=' + $SQLServerName + ';Database=' + $DatabaseName + ';Persist Security Info=False;Integrated Security=SSPI'
    [string]$SQLCommand = "Select Cards.RegNoPrefix, Cards.RegNoValue, Tasks.[Text], StartDate, ActualEndDate, [Status], AuthorId, ApplicantId from 
    (select RegistrationCards.RegNoPrefix, RegistrationCards.RegNoValue, Inquiries.Task_Id, Inquiries.ApplicantId from 
    Inquiries LEFT JOIN RegistrationCards ON Inquiries.RegistrationCard_Id = RegistrationCards.Id) Cards
    Left Join Tasks on Cards.Task_Id = Tasks.Id order by Startdate"

    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($SQLCommand, $conn)
    $cmdR = $cmd.ExecuteReader()
    while ($cmdR.Read()) { 
        Write-Host ==============================================
        #====NK=====
        [int]$RegNoValue = $cmdR['RegNoValue']
        $Owner = get-domainuser-login $cmdR['AuthorId']
        Write-host Author $Author
        Write-host OwnerId $cmdR['ApplicantId']
        $Author = get-domainuser-login $cmdR['ApplicantId']
        Write-host Owner $Owner
        $RegNoPrefix = $cmdR['RegNoPrefix']
        $Text = $cmdR['Text']
        $ww = $cmdR['StartDate']
        #$Title = "16_otd " $RegNoPrefix #" " $RegNoValue $cmdR['StartDate'] $Text.Substring(0,50)
        if ($Text.Length -gt 50) {$Title = $Text.Substring(0,50) } 
        else {$Title = $Text }
        $Title = "16_otd " + $RegNoPrefix + " " + $RegNoValue + " " + $cmdR['StartDate'] + " " +$Title
        if ($cmdR['Status'] -eq 5) {
            $Status = 2
        }
        else {
            $Status = 4
        }
        $ArticleSubject = "16_otd " + $RegNoPrefix + " " + $RegNoValue + " " + $cmdR['StartDate']
        # $Title,    [string] $CustomerLogin,[string] $Owner, [int] $QueryID,  [int] $TicketStateID, # 4-> open, 2 -> closed  [int] $PriorityID,      [Parameter( Mandatory = $true )] [int] $TypeID,
        #   [int] $LockID,      [string] $ArticleSubject,      [string] $ArticleBody
        #$ArticleSubjext = $RegNoPrefix + " " + $RegNoValue
        create-ticket $Title $Author $Owner 11 $Status 3 2 1 $ArticleSubject $Text
        write-host ok
        #create-ticket Title_text PolyakovMV DanilovEB 1 4 3 2 1 test_article_Subject test_article_text
    


    }
}
    
#. "$PSScriptRoot\functions.ticket.ps1"
#get-ticket 76877
#$CIId = get-ConfigItemId Computer 4563
#        Write-Host id $CIId

synch-16-tickets
#F9D639D3-EA53-4DEA-87D5-6CBD9FE308C2
#get-domainuser-login 'C976C3A8-B456-4387-91AB-9EAD1D8DC8F6'