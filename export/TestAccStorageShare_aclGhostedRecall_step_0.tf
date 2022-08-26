

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003348655455"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccd08dt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshared08dt"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}
