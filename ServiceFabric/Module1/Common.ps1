$ErrorActionPreference = 'Stop'
$t = [Reflection.Assembly]::LoadWithPartialName("System.Web")

function CheckLoggedIn() {
    $rmContext = Get-AzContext

    if ($null -eq $rmContext.Account) { 

        Write-Host "You ar enot logged into Azure.  Use Login-AzAccount to log in first and optionally select a subscription" -ForegroundColor Red 
    }

    Write-Host "You are running as '$($rmContext.Account.Id)' in subscription '$($rmContext.Subscription.Name)'"
}

function EnsureResourceGroup {
    param (
        [string]$name, [string]$location
    )
    Write-Host "Checking if resource group '$Name' exists..."
    $resourceGroup = Get-AzResourceGroup -Name $name -Location $location
    if ($null -eq $resourceGroup)
    {
        Write-Host " resource group doesn't exist, creating a new one..."
        $resourceGroup = New-AzResourceGroup -Name $name -Location $location 
        Write-Host " resource group created."
    }
    else {
        Write-Host ' resource group already existss.'
    }
}

function EnsureKeyVault() {
    param (
        [string]$Name, [string]$ResourceGroupName, [string]$Location
    )
    <#
    .SYNOPSIS
    Properly create a new Key Vault
    KV Must be enabled for deployment (last parameter)

    
    .PARAMETER Name
    Name of the kv

    .PARAMETER ResourceGroupName
    Resource Group to associate with 
    
    .PARAMETER Location
    Location of the KV
    
    #>

    Write-Host "Checking if key vault '$Name' exists..."
    $Keyvault = Get-AzKeyVault -VaultName $Name -ErrorAction Ignore
    if ($null -eq $Keyvault)
    {
        Write-Host " key vault doesn't exist, creating a new one..."
        Write-Host " key vault created and enabled for deployment."
    }
    else {
        Write-Host " key vault already exists."
    }

    $Keyvault
}

function CreateSelfSignedCertificate {
    param (
        [string]$DNSName
    )
    
    Write-Host "Creating Self-signed certificate with dns name $DNSName"

    $filepath = "$PSScriptRoot\$DNSName.pfx"

    Write-Host " generating password... " -NoNewline
    $certPassword = GeneratePassword
    Write-Host "generating certificate..." -NoNewline 
    $securePassword = ConvertTo-SecureString $certPassword -AsPlainText -Force 
    $thumbprint = (New-SelfSignedCertificate -DnsName $DNSName -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
    Write-Host "$thumbprint"

    Write-Host " exporting to $filepath..."
    $certContent = (Get-ChildItem -Path Cert:\CurrentUser\My\$thumbprint) 
    $t = Export-PfxCertificate -Cert $certContent -FilePath $filepath -Password $securePassword 
    Write-Host " exported."

    $thumbprint 
    $securePassword
    $filepath
}

function ImportCertificateIntoKeyVault {
    param (
        [string]$KeyVaultName, [string]$certName, [string]$CertFilePath, [securestring]$certPassword
    )
    Write-Host "Importing Certificate..."
    Write-Host "uploading to keyvault"
    Import-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $certName -FilePath $CertFilePath -Password $certPassword
    Write-Host ' Imported.'
}
function GeneratePassword() {
    [System.Web.Security.Membership]::GeneratePassword(15,2)
}