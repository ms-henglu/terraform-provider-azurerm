

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012108825890"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa8dz91"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220916012108825890"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220916012108825890"
  row_key       = "test_row220916012108825890"
  entity = {
    Foo              = 123
    "Foo@odata.type" = "Edm.Int32"
    Test             = "Updated"
  }
}
