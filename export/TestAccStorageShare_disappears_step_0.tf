

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722052559543090"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccpf4o2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharepf4o2"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
