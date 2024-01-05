
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240105064524777843"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-240105064524777843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct0mqz0"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_resource_deployment_script_azure_power_shell" "test" {
  name                = "acctest-rdsaps-240105064524777843"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "8.3"
  retention_interval  = "P1D"
  command_line        = "-name \"John Dole\""
  cleanup_preference  = "OnSuccess"
  force_update_tag    = "1"
  timeout             = "PT30M"

  script_content = <<EOF
		param([string] $name)
      	$output = 'Hello {0}. The username is {1}, the password is {2}.' -f $name,$${Env:UserName},$${Env:Password}
      	Write-Output $output
      	$DeploymentScriptOutputs = @{}
      	$DeploymentScriptOutputs['text'] = $output
EOF

  supporting_script_uris = ["https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/deployment-script/create-cert.ps1"]

  container {
    container_group_name = "cgn-240105064524777843"
  }

  environment_variable {
    name  = "UserName"
    value = "jdole"
  }

  environment_variable {
    name         = "Password"
    secure_value = "jDolePassword"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  storage_account {
    name = azurerm_storage_account.test.name
    key  = azurerm_storage_account.test.primary_access_key
  }

  tags = {
    key = "value"
  }

}
