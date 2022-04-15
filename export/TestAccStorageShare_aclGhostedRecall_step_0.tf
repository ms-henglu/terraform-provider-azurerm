

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031155634615"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccvvr2i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharevvr2i"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}
