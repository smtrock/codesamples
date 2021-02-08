[CmdletBinding()]
param (
    [Parameter(Mandatory= $true)]
    [string]
    $Name
)

. "$PSScriptRoot\Common.ps1"

$ResourceGroup = "PS-M2-$Name"
$Location = "East US"
$KeyVaultName = "$Name-psm2vault"
CheckLoggedIn

EnsureResourceGroup $ResourceGroup $Location

$Keyvault = EnsureKeyVault $KeyVaultName $resourceGroup

$certThumbprint, $certPassword, $certPath = CreateSelfSignedCertificate $name

$kvCert = ImportCertificateIntoKeyVault $KeyVaultName $name $certPath $certPassword

# $armParameters = @{
#     namePart = $Name;
#     certificateThumbprint= $certThumbprint;
#     sourceVaultResourceId = $Keyvault.ResourceId;
#     certificateUrlValue = $kvCert.SecretId;
#     rdpPassword = GeneratePassword;

# }

# New-AzResourceGroupDeployment `
#     -ResourceGroupName $ResourceGroupName `
#     -TemplatFile "$PSScriptRoot\minimal.json" `
#     -Mode Incremental `
#     -TemplateParameterObject $armParameters `
#     -Verbose 