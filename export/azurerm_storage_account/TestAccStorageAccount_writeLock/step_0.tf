

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-221028172851923772"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctli6w0"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}


resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221028172851923772"
  scope      = azurerm_storage_account.test.id
  lock_level = "ReadOnly"
}
