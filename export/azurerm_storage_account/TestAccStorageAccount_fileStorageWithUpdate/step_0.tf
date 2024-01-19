
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908573348"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct4pbox"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  tags = {
    environment = "production"
  }
}
