
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825032125503070"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccw7rw2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst210825032125503070"
  storage_account_name = azurerm_storage_account.test.name
}
