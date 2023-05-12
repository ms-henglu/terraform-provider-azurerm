
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-role-assigment-230512003439933406"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23xst2acctmbpei"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_role_assignment" "test" {
  name                 = "fe3c5639-66be-4abc-9c89-8b37da3add28"
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}
