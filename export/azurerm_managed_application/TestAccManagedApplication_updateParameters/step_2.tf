

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Contributor"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-230106031644015322"
  location = "West Europe"
}

resource "azurerm_managed_application_definition" "test" {
  name                = "acctestManagedAppDef230106031644015322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lock_level          = "ReadOnly"
  package_file_uri    = "https://github.com/Azure/azure-managedapp-samples/raw/master/Managed Application Sample Packages/201-managed-storage-account/managedstorage.zip"
  display_name        = "TestManagedAppDefinition"
  description         = "Test Managed App Definition"
  package_enabled     = true

  authorization {
    service_principal_id = data.azurerm_client_config.test.object_id
    role_definition_id   = split("/", data.azurerm_role_definition.test.id)[length(split("/", data.azurerm_role_definition.test.id)) - 1]
  }
}


resource "azurerm_managed_application" "test" {
  name                        = "acctestManagedApp230106031644015322"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  kind                        = "ServiceCatalog"
  managed_resource_group_name = "infraGroup230106031644015322"
  application_definition_id   = azurerm_managed_application_definition.test.id

  parameter_values = <<VALUES
	{
        "location": {"value": "${azurerm_resource_group.test.location}"},
        "storageAccountNamePrefix": {"value": "storecnilc"},
        "storageAccountType": {"value": "Standard_LRS"}
	}
  VALUES
}
