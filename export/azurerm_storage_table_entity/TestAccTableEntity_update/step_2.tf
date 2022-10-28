

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172852564716"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa9sqhi"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst221028172852564716"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition221028172852564716"
  row_key       = "test_row221028172852564716"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
