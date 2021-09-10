
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021928746792"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc3ql8y"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst210910021928746792"
  storage_account_name = azurerm_storage_account.test.name
}
