

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220603005354805739"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctv88a7"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}


resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603005354805739"
  scope      = azurerm_storage_account.test.id
  lock_level = "ReadOnly"
}
