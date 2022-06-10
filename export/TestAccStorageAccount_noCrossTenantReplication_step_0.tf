
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220610023200555702"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct9aq3p"
  resource_group_name = azurerm_resource_group.test.name

  location                         = azurerm_resource_group.test.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  cross_tenant_replication_enabled = false

  tags = {
    environment = "production"
  }
}
