
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-role-assigment-210830083701095333"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23xst2acctqax44"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_role_assignment" "test" {
  name                 = "555bfa37-8355-4ac9-b9dc-fad746e237eb"
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}
