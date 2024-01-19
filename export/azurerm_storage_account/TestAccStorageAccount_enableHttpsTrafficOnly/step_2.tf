
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908566249"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct8me8y"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = false

  tags = {
    environment = "production"
  }
}
