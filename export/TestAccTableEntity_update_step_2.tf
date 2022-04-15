

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031155643863"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaglad2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220415031155643863"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220415031155643863"
  row_key       = "test_row220415031155643863"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
