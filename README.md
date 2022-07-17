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

# AD Forrest
1. From the Management Client, enter the PSSession for DC-1
    """
    Import-Module ADDSDeployment
    Install-ADDSForrest
    """
2. I gave my forrest the name of homelab.local and enter a Safe Mode password
3. After the forrest is installed, the DNS settings get set to a loopback address and will need to be reset to the DNS IP address (We will use the DC-1 IP address for DNS)
4. From the management client:
    - Get the interface index for DC-1
        """
        Get-NetIPAddress -IPAddress {IP address of DC-1}
        """
    - InterfaceIndex: 6
5. Setting the DNS to the IP address of DC-1 and confirm the change has taken place
    """
    Set-DnsClientServerAddress -InterfaceIndex {Interface Index number} -ServerAddresses {IP address of DC-1}
    
    Get-DNSClinetServerAddress
    """
    