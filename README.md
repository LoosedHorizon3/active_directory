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
    - Opened PowerShell as administrator
    - Started the WinRM service
        """
        Start-Service WinRM
        """
    - Added DC-1 to the trusted computers
        """
        Set-Item WSMan:\localhost\Client\TrustedHosts -value {DC-1 IP Address}
        """

5. Install Active Directory
    - On the Management Clinet we created a new PS Session to connect to DC-1 within PowerShell
        """
        New-PSSession -Computername {DC-1 IP Address} -Credentials (Get-Credentials)
        Enter-PSSession {Session ID}
        """
    - Once connected to DC-1 we isntalled Windows Active Directory
        """
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        """

# AD Forrest
1. From the Management Client, enter the PSSession for DC-1 with PowerShell
    """
    Import-Module ADDSDeployment
    Install-ADDSForrest
    """
2. I gave my forrest the name of homelab.local and enter a Safe Mode password
3. After the forrest is installed, the DNS settings get set to a loopback address and will need to be reset to the DNS IP address (We will use the DC-1 IP address for DNS)
4. From the management client:
    - Get the interface index for DC-1, with PowerShell
        """
        Get-NetIPAddress -IPAddress {IP address of DC-1}
        """
    - InterfaceIndex: 6
5. Setting the DNS to the IP address of DC-1 and confirm the change has taken place
    """
    Set-DnsClientServerAddress -InterfaceIndex {Interface Index number} -ServerAddresses {IP address of DC-1}
    
    Get-DNSClinetServerAddress
    """

# Joining a Workstation
1. We cloned the Win11 Workstation template as a linked clone and named it WS-01
2. Once logged in, we changed the DNS IP address to point to DC-1 so we can join the local domain
    """
    Get-NetIPAddress -IPAddress {IP address of WS-01}
    """
    - InterfaceIndex: 3
    """
    Set-DnsClientServerAddress -InterfaceIndex {Interface Index number} -ServerAddresses {IP address of DC-1}
    
    Get-DNSClinetServerAddress
    """
3. Now that the DNS settings have been changed, we can now join the domain
    - In PowerShell
    """
    Add-Computer -DomainName homelab.local -Credential homelab.local\Administrator -Force -Restart
    """

# Creating and Adding Domain Users
1. Created a simple json file to be able to replicate users within the Management Client
2. In PowerShell we created a variable so we can easily connect to the DC-1 via PSSession
    """
    $dc = New-PSSession {IP address of DC-1} -Credential (Get-Credential)
    """
3. We created a PowerShell script called "gen_ad.ps1"
    - To excuate PowerShell scripts we must enable the feature to run scripts
    - In PowerShell
        """
        Set-ExecutionPolicy RemoteSigned
        """
4. Created a json file so we can create a user with groups in Active Directory
    - The json file is called ad_schema.json
5. Once the variable has been created we use PowerShell to copy over the json and script files from the Management Client to DC-1
    """
    Copy-Item .\ad_schema.json -ToSession $dc {file path to store on DC-1}
    Copy-Item .\gen_ad.ps1 -ToSession $dc {file path to store on DC-1}
    """