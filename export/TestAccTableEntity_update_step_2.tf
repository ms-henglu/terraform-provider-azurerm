

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034550846915"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaj2ii6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220107034550846915"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220107034550846915"
  row_key       = "test_row220107034550846915"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
