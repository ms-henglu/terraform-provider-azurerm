
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010320421230"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc9qp8j"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220506010320421230"
  storage_account_name = azurerm_storage_account.test.name
}
