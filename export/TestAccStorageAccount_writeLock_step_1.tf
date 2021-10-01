

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211001021258829194"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctgg7d6"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}


resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211001021258829194"
  scope      = azurerm_storage_account.test.id
  lock_level = "ReadOnly"
}
