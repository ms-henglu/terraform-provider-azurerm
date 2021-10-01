

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021259462969"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccol39e"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_queue" "test" {
  name                 = "mysamplequeue-211001021259462969"
  storage_account_name = azurerm_storage_account.test.name
}
