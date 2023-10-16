
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231016034824350241"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctefmk3"
  resource_group_name = azurerm_resource_group.test.name

  location                          = azurerm_resource_group.test.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
}
