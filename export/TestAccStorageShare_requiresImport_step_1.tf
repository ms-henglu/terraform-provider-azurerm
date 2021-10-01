


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021259584032"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc3dmwh"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testshare3dmwh"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_share" "import" {
  name                 = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_share.test.storage_account_name
}
