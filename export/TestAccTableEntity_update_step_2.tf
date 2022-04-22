

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422025856872318"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa3fiw3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220422025856872318"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220422025856872318"
  row_key       = "test_row220422025856872318"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
