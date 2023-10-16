
provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231016034824351121"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctjn3gr"
  resource_group_name = azurerm_resource_group.test.name

  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  default_to_oauth_authentication = true

  tags = {
    environment = "production"
  }
}
