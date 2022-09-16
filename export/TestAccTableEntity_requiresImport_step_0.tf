

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012108823344"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsar0ph9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220916012108823344"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220916012108823344"
  row_key       = "test_row220916012108823344"
  entity = {
    Foo = "Bar"
  }
}
