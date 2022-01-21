


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121045053048618"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsag2mb4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220121045053048618"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220121045053048618"
  row_key       = "test_row220121045053048618"
  entity = {
    Foo = "Bar"
  }
}


resource "azurerm_storage_table_entity" "import" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220121045053048618"
  row_key       = "test_row220121045053048618"
  entity = {
    Foo = "Bar"
  }
}
