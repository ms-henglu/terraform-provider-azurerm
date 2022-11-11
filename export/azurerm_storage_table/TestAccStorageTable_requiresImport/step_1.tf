

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111021253904984"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccbcl1x"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221111021253904984"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table" "import" {
  name                 = azurerm_storage_table.test.name
  storage_account_name = azurerm_storage_table.test.storage_account_name
}
