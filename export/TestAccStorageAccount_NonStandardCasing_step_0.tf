
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211015014900657831"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctf0qkf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "standard"
  account_replication_type = "lrs"

  tags = {
    environment = "production"
  }
}
