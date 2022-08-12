
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-role-assigment-220812014637244983"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23xst2acctd29t1"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_role_assignment" "test" {
  name                 = "56973b61-6d26-4438-8693-0a825994751c"
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}
