
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014332646766"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccfga43"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
