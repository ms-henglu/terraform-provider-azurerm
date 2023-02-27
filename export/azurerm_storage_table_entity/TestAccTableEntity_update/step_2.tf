

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033508508703"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsagsxvm"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230227033508508703"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition230227033508508703"
  row_key       = "test_row230227033508508703"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
