

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025124957338"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccl87ff"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharel87ff"
  storage_account_name = azurerm_storage_account.test.name

  metadata = {
    hello = "world"
    happy = "birthday"
  }
}
