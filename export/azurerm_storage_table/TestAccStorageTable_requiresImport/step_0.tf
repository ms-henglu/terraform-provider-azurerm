
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124154337698"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchi6vr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst240315124154337698"
  storage_account_name = azurerm_storage_account.test.name
}
