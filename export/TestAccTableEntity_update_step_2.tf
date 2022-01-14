

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014844332657"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1zxho"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220114014844332657"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220114014844332657"
  row_key       = "test_row220114014844332657"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
