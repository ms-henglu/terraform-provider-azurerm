
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021259587299"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc7074a"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst211001021259587299"
  storage_account_name = azurerm_storage_account.test.name
}
