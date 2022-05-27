

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034746876735"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacctws2f"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharetws2f"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}
