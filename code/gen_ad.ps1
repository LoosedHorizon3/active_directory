param([Parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup {
    param([Parameter(Mandatory=$true)] $GroupObject)

    $GroupName = $GroupObject.name
    New-ADGroup -name $GroupName -GroupScope Global

}

function RemoveADGroup {
    param([Parameter(Mandatory=$true)] $GroupObject)

    $GroupName = $GroupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false

}

function  CreateADUser(){
    param([Parameter(Mandatory=$true)] $UserObject)    
    # Pull out the name from the JSON object
    $Name = $UserObject.name
    # Pull out the generic password from the JSON object
    $Password = $UserObject.password
    #Splitting the name from the JSON object into first name and surname
    $GivenName, $Surname = $Name.Split(" ")
    # Generate a username from the $name variable as "first initial, surname" all in lowercase
    $Username = ($GivenName[0] + $Surname).ToLower()

    # Creating an AD User account
    New-ADUser -Name $Name -GivenName $GivenName -Surname $Surname -SamAccountName $Username -UserPrincipalName $Username@$Global:Domain -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -PassThru | Enable-ADAccount
    
    # Adding the user to the AD Group(s)
    foreach($GroupName in $UserObject.groups){
         Try{
             Get-ADGroup -Identity $GroupName
             Add-ADGroupMember -Identity $GroupName -Members $Username
         }
         Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
             Write-Warning "User $User could not be added to group $GroupName as the group does not exist"
         }
    }

}

function WeakenPasswordPolicy {
        secedit /export /cfg C:\Windows\Tasks\secpol.cfg
	  # Changed the password complexity to false - Password don't need to be complex now
        (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\Windows\Tasks\secpol.cfg
        # Changing the minimum password length from the default 7 to 1
	  (Get-Content C:\Windows\Tasks\secpol.cfg).replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
        secedit /configure /db C:\Windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
        Remove-Item -Force C:\Windows\Tasks\secpol.cfg -Confirm:$false    
}

WeakenPasswordPolicy

$json = (Get-Content $JSONFile | ConvertFrom-Json)

$Global:Domain = $json.domain

foreach($Group in $json.groups){ 
    CreateADGroup $Group
}

foreach($User in $json.users){
    CreateADUser $User
}