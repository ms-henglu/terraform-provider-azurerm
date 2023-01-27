
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-role-assigment-230127045005247769"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23xst2acctqjo3w"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_role_assignment" "test" {
  name                 = "ea5041ca-ce29-46e7-95f9-37851fcd79a2"
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}
