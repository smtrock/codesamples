[CmdletBinding()]
param (
    [Parameter(Mandatory= $true)]
    [string]
    $Name
)

. "$PSScriptRoot\Common.ps1"

$ResourceGroup = "PS-M2-$Name"
$KeyVaultName = "$Name-psm2vault"
CheckLoggedIn

EnsureResourceGroup $ResourceGroup $Location

$Keyvault = EnsureKeyVault $KeyVaultName $resourceGroup $Location

$certThumbprint, $certPassword, $certPath = CreateSelfSignedCertificate $name

$kvCert = ImportCertificateIntoKeyVault $KeyVaultName $name $certPath $certPassword

$armParameters = @{
    namePart = $Name;
    certificateThumbprint= $certThumbprint;
    sourceVaultResourceId = $Keyvault.ResourceId;
    certificateUrlValue = $kvCert.SecretId;
    rdpPassword = GeneratePassword;

}

$template = Get-ChildItem $(Join-Path $PSScriptRoot 'minimal.json') # $PSScriptRoot
New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroup `
    -TemplatFile $template.FullName `
    -Mode Incremental `
    -TemplateFile $armParameters `
    -Verbose 