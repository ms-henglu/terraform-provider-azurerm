

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111021253902520"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1e22p"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221111021253902520"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition221111021253902520"
  row_key       = "test_row221111021253902520"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
