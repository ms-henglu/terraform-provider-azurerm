

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326011300727830"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaeh69z"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220326011300727830"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220326011300727830"
  row_key       = "test_row220326011300727830"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
