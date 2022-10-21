

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034640217859"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccxb8yt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-221021034640217859"
  storage_account_name = azurerm_storage_account.test.name
}
