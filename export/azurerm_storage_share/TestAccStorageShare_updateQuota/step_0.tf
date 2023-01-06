

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106032017987720"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc2rq9d"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare2rq9d"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
