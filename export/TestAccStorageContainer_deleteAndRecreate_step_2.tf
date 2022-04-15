
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031155525049"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestacc6hgys"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}
