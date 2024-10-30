Simple Powershell script to lookup info about a user or computer in ActiveDirectory.

*Requirements*
Download Remote Server Administration Tools for Windows (RSAT).
Official Instructions: 
https://learn.microsoft.com/en-us/troubleshoot/windows-server/system-management-components/remote-server-administration-tools

Direct link:
https://www.microsoft.com/en-us/download/details.aspx?id=45520


*Usage*

For devices, responds with last logon time ([both local DC and AD replicated](https://serverfault.com/questions/734615/lastlogon-vs-lastlogontimestamp-in-active-directory)), IP Address, current device powered on state, and current login state for devices.

For users, responds with last logon time, ID number, and display name.

*NOTE* 
The "LastLogon" field is NOT when a user last logged in. Read [here](https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/8220-the-lastlogontimestamp-attribute-8221-8211-8220-what-it-was/ba-p/396204)

Commands:
-anydc : Returns recent login details from accross all domain controllers. Most recent is most likely true.
-user : Force to treat input as a user name.
-comp : Force to treat input as a device name.


