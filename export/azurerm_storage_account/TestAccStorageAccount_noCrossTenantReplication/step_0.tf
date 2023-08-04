
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230804030800769856"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctbzpbl"
  resource_group_name = azurerm_resource_group.test.name

  location                         = azurerm_resource_group.test.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  cross_tenant_replication_enabled = false

  tags = {
    environment = "production"
  }
}
