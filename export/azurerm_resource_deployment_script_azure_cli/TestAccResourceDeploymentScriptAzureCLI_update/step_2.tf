
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013044152768359"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-231013044152768359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct1loqx"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_resource_deployment_script_azure_cli" "test" {
  name                = "acctest-rdsac-231013044152768359"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "2.40.0"
  retention_interval  = "P1D"
  command_line        = "'foo' 'bar'"
  cleanup_preference  = "OnSuccess"
  force_update_tag    = "1"
  timeout             = "PT30M"

  script_content = <<EOF
            echo "{\"name\":{\"displayName\":\"$1 $2\"}, \"UserName\":\"$UserName\", \"Password\":\"$Password\"}" > $AZ_SCRIPTS_OUTPUT_PATH
  EOF

  supporting_script_uris = ["https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/deployment-script/create-cert.ps1"]

  container {
    container_group_name = "cgn-231013044152768359"
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
    key = "value2"
  }

}
