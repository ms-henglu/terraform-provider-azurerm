

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052819934891"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestacch7m09"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_container" "test" {
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
