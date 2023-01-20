

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052820037219"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc1va6m"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare1va6m"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
