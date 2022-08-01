Param(
  # Your subscription on which you want to create a App Registration
  [Parameter(Mandatory = $true)]
  [string]
  $subscriptionId,

  # The name of the Resource Group which will be created
  [Parameter(Mandatory = $true)]
  [string]
  $resourceGroupName
)

# $subscriptionId = '76c3f98d-bbf6-4b35-9348-1f9ffa28d6ed'
# $resourceGroupName = 'TerraformDemo'

# create App Registration
$appRegistration = az ad app create --display-name "GitHub-Actions" | ConvertFrom-Json

# create Service Principal
$servicePrincipal = az ad sp create --id ($appRegistration.appId) | ConvertFrom-Json

az group create --location "West Europe" --name $resourceGroupName

# create Role Assignment for the new Service Principal
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id  ($servicePrincipal.id) --assignee-principal-type ServicePrincipal --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName


# this commands throws 404 for some reason => create federated client manually in azure portal
#Invoke-AzRestMethod -Method POST -Uri 'https://graph.microsoft.com/beta/applications/<Object-ID>/federatedIdentityCredentials' -Payload  '{"name":"<Name>","issuer":"https://token.actions.githubusercontent.com","subject":"repo:pgaag/iaac_azure_demo:ref:refs/heads/main","description":"Testing","audiences":["api://AzureADTokenExchange"]}'