

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035414373371"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccl2nwz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221222035414373371"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table" "import" {
  name                 = azurerm_storage_table.test.name
  storage_account_name = azurerm_storage_table.test.storage_account_name
}
