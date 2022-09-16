
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220916012108369872"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsakrs2i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
