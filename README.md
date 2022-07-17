# Active Directory Setup

# Setup Base Template VMs
1. Server Template:
    - Installed the Windows Server 2022 as a Virtual Machine in VMWare Workstation
    - Installed VMWare Tools
    - Updated the server to the latest patch (19-07-22)

2. Workstation Template: 
    - Install Windows 11 as a Virtual Machine in VMWare Workstation 
    - Installed VMWare Tools
    - Updated the workstation to the latest patch (19-07-22)


# Install Domain Controller
1. Made a linked colne of the Server template
2. On the cloned server we used SCcinfig to:
    - Changed the hostname of the server to DC-1
    - Changed the IP address to static
    - Changed the primary DNS server IP to IP address of the new static IP of DC-1

3. Made a linked clone of the Workstation template to be used as a Management Clinet for DC-1
4. On the cloned workstation:
    - Opened windows terminal as administrator
    - Started the WinRM service
        """
        Start-Service WinRM
        """
    - Added DC-1 to the trusted computers
        """
        Set-Item WSMan:\localhost\Client\TrustedHosts -value {DC-1 IP Address}
        """

5. Install Active Directory
    - On the Management Clinet we created a new PS Session to connect to DC-1
        """
        New-PSSession -Computername {DC-1 IP Address} -Credentials (Get-Credentials)
        Enter-PSSession {Session ID}
        """
    - Once connected to DC-1 we isntalled Windows Active Directory
        """
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        """
