# OTRS_PS
## Overview

Powershell functions for OTRS SOAP API for work with CMDB classes, LinkObjects, Tickets and Articles.

### For use this set of scripts - you have to:
- copy folders in certain place and make same setup.
1) Folders ArticleBackendObject and LinkObject to path "/otrs/Custom/Kernel/GenericInterface/Operation/"
2) XML files copy to path "/otrs/Kernel/Config/Files/XML/"
3) Rebuild config - "perl bin/otrs.Console.pl Maint::Config::Rebuild"
4) Go to OTRS config - "GeneralInterface::Operation::ModuleRegistration" and enable new Operations:
 - ArticleBackendObject::ArticleCreate
 - LinkObject::LinkAdd
 - LinkObject::LinkDelete
 - LinkObject::LinkList
 5) Go to "Admin - Web Services". Create new Webservices or import files from folder WebServices_exportfiles. In examples uses Webservices names - WS_CI and WS_Ticket
 6) Create user for scripts with needed rights. For example - create CMDB objects.
 6) Create and fill Set-GlobalVars.ps1
 Require Userdata, url, SOAPNameSpace.
 
 For use additional functions for classes in [OTRS 6 API](https://doc.otrs.com/doc/api/otrs/6.0/Perl/) - have to create backend perl module with functions for your operations and create XML file with description of new operation.
  
 CMDB sample classes yaml files in folder "CMDB Config".
 Notice for separate class for Printer.(not necessary - this for my sample script imports and sync CMDB objects)

You make debug Web services on page Webservice - Debugger and Log your http server.

sync.tickets.ps1 - example import tickets from third tickets system
sync.printers.ps1 - example periodic imports CMDB objects Printers from asset system
sync.links.ps1 - example periodic linkin object sync with data collecting from active network switches
