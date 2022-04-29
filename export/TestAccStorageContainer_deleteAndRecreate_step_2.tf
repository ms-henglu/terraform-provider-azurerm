
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429070127852383"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestaccpxgb9"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}
