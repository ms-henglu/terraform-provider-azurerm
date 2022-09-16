
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220916012108361065"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accty3wtp"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  queue_properties {
    logging {
      version               = "1.0"
      delete                = true
      read                  = true
      write                 = true
      retention_policy_days = 7
    }
  }
}
