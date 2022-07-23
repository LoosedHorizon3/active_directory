param([Parameter(Mandatory=$true)] $OutputJSONFile)

$Domain = "homelab.local"
$GroupNames = [System.Collections.ArrayList](Get-Content "code\data\group_names.txt")
$Surnames = [System.Collections.ArrayList](Get-Content "code\data\Surname.txt")
$GivenNames = [System.Collections.ArrayList](Get-Content "code\data\GivenNames.txt")
$Password = [System.Collections.ArrayList](Get-Content "code\data\Passwords.txt")

$Groups = @()

$num_groups = 10

for ($i = 0; $i -lt $num_groups; $i++){
        $NewGroup = (Get-Random -InputObject $GroupNames)
        $Groups += @{"name" = "$NewGroup"}
        $GroupNames.Remove($NewGroup)
}


$num_users = 100
$User = @()

for ($i = 0; $i -lt $num_users; $i++){
    $FirstName = (Get-Random -InputObject $GivenNames)
    $LastName = (Get-Random -InputObject $Surnames)
    $PasswordGiven = (Get-Random -InputObject $Password)
    $NewUser = @{
        "name"="$FirstName $LastName";
        "password"="$PasswordGiven"
        "groups" = @(Get-Random -InputObject $Groups).name
    }
    $User += $NewUser
    $GivenNames.Remove($FirstName)
    $Surnames.Remove($LastName)
    $Password.Remove($PasswordGiven)
}

ConvertTo-Json -InputObject @{
    "domain" = $Domain
    "groups" = $Groups
    "users" = $User
}  | Out-File $OutputJSONFile
#| ForEach-Object {ConvertTo-Json @($_)} | Out-File $OutputJSONFile