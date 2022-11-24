
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-221124182408363568"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctln3sa"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}
