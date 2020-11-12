$WebServiceName = "WS_Ticket"
function new-ticket {
   <#
   .SYNOPSIS
   OTRS SOAP Action for create Ticket
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER TITLE
   Ticket Title
   .PARAMETER CUSTOMERLOGIN 
   Customer User login
   .PARAMETER OWNER
   Agent - owner ticket
   .PARAMETER QUERYID
   id from table QUERY
   .PARAMETER TicketStateID
   id from table ticket_state. Default 1=new,2=closed success,4=open
   .PARAMETER PriorityID
   id from table ticket_priority. Default 2=low,3=normal,4=high
   .PARAMETER TypeID
   id from table ticket_type. Default 1=Unclassified,2=Incident
   .PARAMETER LockID
   id from table ticket_lock_type. 1=unlock, 2=lock
   .PARAMETER ArticleSubject
   Article title
   .PARAMETER ArticleBody
   Article text
   .EXAMPLE
   new-ticket Title_text PolyakovMV DanilovEB 1 4 3 2 1 test_article_Subject test_article_text
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [string] $Title,
      [Parameter( Mandatory = $true )] [string] $CustomerLogin,
      [Parameter( Mandatory = $true )] [string] $Owner,
      [Parameter( Mandatory = $true )] [int] $QueryID, # 1
      [Parameter( Mandatory = $true )] [int] $TicketStateID, # 4-> open, 2 -> closed
      [Parameter( Mandatory = $true )] [int] $PriorityID,
      [Parameter( Mandatory = $true )] [int] $TypeID,
      [int] $LockID,
      [string] $ArticleSubject,
      [string] $ArticleBody
   )
   
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   $ArticleSubject = $ArticleSubject.Replace('<',' ').Replace('>','').Replace('&','')
   $ArticleBody = $ArticleBody.Replace('<',' ').Replace('>','').Replace('&','')

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $OperationName = "Operation_TicketCreate"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
   <soapenv:Body>
      <tic:$OperationName>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
      <Ticket>
                <Title>$Title</Title>
                <CustomerUser>$CustomerLogin</CustomerUser>
                <CustomerID>$CustomerID</CustomerID>
                <QueueID>$QueryID</QueueID>
                <StateID>$TicketStateID</StateID>
                <PriorityID>$PriorityID</PriorityID>
                <TypeID>$TypeID</TypeID>
                <Owner>$Owner</Owner>
                <LockID>$LockID</LockID>
         </Ticket>
         <Article>
             <Subject>$ArticleSubject</Subject>
             <Body>$ArticleBody</Body>
             <ContentType>text/plain; charset=utf8</ContentType>
         </Article>
      </tic:$OperationName>
   </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$id = ([xml]$data).Envelope.Body.Operation_TicketCreateResponse.ArticleID
return $id
}

function new-article{
   <#
   .SYNOPSIS
   OTRS SOAP Action for create article for Ticket
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   and copy backend perl module.
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER TicketID
   Number of ConfigItem
   .PARAMETER ChatterID
   id agent user
   .PARAMETER IsVisibleForCustomer 
   bool: 1 | 0
   .PARAMETER SenderType
   Agent | System | Customer
   .PARAMETER UserID
   User id - 4 = srv_otrs
   .EXAMPLE
   new-article 89858 agent 4 1 4 "article_body"
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
    [Parameter( Mandatory = $true )] [int] $TicketID,
    [Parameter( Mandatory = $true )] [string] $SenderType,
    [Parameter( Mandatory = $true )] [int] $ChatterID, # 4- srv_otrs
    [Parameter( Mandatory = $true )] [int] $IsVisibleForCustomer,
    [Parameter( Mandatory = $true )] [int] $UserID,
    [Parameter( Mandatory = $true )] [string] $MessageText
   )
  
   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $MessageText = $MessageText.Replace('<',' ').Replace('>','').Replace('&','')
   $CreateTime = Get-Date -Format u

   $OperationName = "Operation_ArticleCreate"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
   <soapenv:Body>
         <tic:$OperationName>
            <UserLogin>$UserLogin</UserLogin>
            <Password>$Password</Password>
            <ArticleBackendObject>ArticleCreate</ArticleBackendObject>
            <TicketID>$TicketID</TicketID>
            <SenderType>$SenderType</SenderType>
            <IsVisibleForCustomer>$IsVisibleForCustomer</IsVisibleForCustomer>
            <UserID>$UserID</UserID>
            <ChatterID>$ChatterID</ChatterID>
            <ChatterName>srv_otrs ttt</ChatterName>
            <MessageText>$MessageText</MessageText>
            <CreateTime>$CreateTime</CreateTime>
            <HistoryType>AddNote</HistoryType>
         </tic:$OperationName>
      </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$id = ([xml]$data).Envelope.Body.Operation_TicketCreateResponse.ArticleID
return $id
}

function get-ticket{
<#
   .SYNOPSIS
   OTRS SOAP Action for get Ticket
   .DESCRIPTION
   For use this functions you have to create SOAP Webservice with named operation
   Webservice yaml files, modules and more detail: https://github/daniloveb/otrs_ps
   .PARAMETER TicketID
   Ticket Id. Requied, could be coma separated IDs or an Array. ,'32,33',
   .PARAMETER DynamicFields 
   Optional, 0 as default 
   .PARAMETER Extended
   Optional, 0 as default. Set as 1 will includes articles
   .PARAMETER AllArticles
   Optional
   .PARAMETER ArticleSenderType
   Optional, [ $ArticleSenderType1, $ArticleSenderType2 ],
   .PARAMETER ArticleOrder
   Optional, DESC/ASC, default as ASC
   .PARAMETER ArticleLimit
   Optional 0/1
   .PARAMETER Attachments
   Optional, 0 as default. 0/1 
   .PARAMETER GetAttachmentContents
   Optional 0/1
   .PARAMETER HTMLBodyAsAttachment
   Optional 0/1
   .EXAMPLE
   get-ticket 456
   $Age=(get-ticket 4839)['Age']
   .LINK
   https://github/daniloveb/otrs_ps
   #>
   [CmdletBinding()]
	param (
      [Parameter( Mandatory = $true )] [int32] $TicketID,
      [int] $DynamicFields,
      [int] $Extended,
      [int] $AllArticles,
      [string] $ArticleSenderType,
      [string] $ArticleOrder,
      [int] $ArticleLimit,
      [int] $Attachments,
      [int] $GetAttachmentContents,
      [int] $HTMLBodyAsAttachment
   )

   . "$PSScriptRoot\functions.SOAP.ps1"
   . "$PSScriptRoot\Set-GlobalVars.ps1"

   Write-Debug "$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0])"
   $Logger.AddInfoRecord("$($MyInvocation.MyCommand.Name) $($MyInvocation.BoundParameters.Values[0]) ")

   $OperationName = "Operation_TicketGet"

$XMLData = @"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="$SoapNameSpace">
   <soapenv:Body>
      <tic:$OperationName>
         <UserLogin>$UserLogin</UserLogin>
         <Password>$Password</Password>
         <TicketID>$TicketID</TicketID>
         <DynamicFields>$DynamicFields</DynamicFields>
         <Extended>$Extended</Extended>
         <AllArticles>$AllArticles</AllArticles>
         <ArticleSenderType>$ArticleSenderType</ArticleSenderType>
         <ArticleOrder>$ArticleOrder</ArticleOrder>
         <ArticleLimit>$ArticleLimit</ArticleLimit>
         <Attachments>$Attachments</Attachments>
         <GetAttachmentContents>$GetAttachmentContents</GetAttachmentContents>
         <HTMLBodyAsAttachment>$HTMLBodyAsAttachment</HTMLBodyAsAttachment>
      </tic:$OperationName>
   </soapenv:Body>
</soapenv:Envelope>
"@

$data = request-SOAP $WebServiceName $OperationName $XMLData
$result = @{}
$result.add("Age",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Age)
$result.add("ArchiveFlag",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.ArchiveFlag)
$result.add("ChangeBy",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.ChangeBy)
$result.add("Changed",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Changed)
$result.add("CreateBy", ([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.CreateBy)
$result.add("Created",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Created)
$result.add("CustomerID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.CustomerID)
$result.add("CustomerUserID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.CustomerUserID)
$result.add("Lock",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Lock)
$result.add("Owner",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Owner)
$result.add("OwnerID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.OwnerID)
$result.add("Priority",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Priority)
$result.add("PriorityID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.PriorityID)
$result.add("Queue",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Queue)
$result.add("QueueID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.QueueID)
$result.add("State",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.State)
$result.add("StateID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.StateID)
$result.add("StateType",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.StateType)
$result.add("TicketID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.TicketID)
$result.add("TicketNumber",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.TicketNumber)
$result.add("Title",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Title)
$result.add("Type",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.Type)
$result.add("TypeID",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.TypeID)
$result.add("UnlockTimeout",([xml]$data).Envelope.Body.Operation_TicketGetResponse.Ticket.UnlockTimeout)
return $result
}


