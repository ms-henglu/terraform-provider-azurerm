

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041948491672"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestaccwkzj7"
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
