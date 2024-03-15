
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124154333809"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaw9nhd"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst240315124154333809"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_table_entity" "test" {
  storage_table_id = azurerm_storage_table.test.id

  partition_key = "test_partition240315124154333809"
  row_key       = "test_row240315124154333809"
  entity = {
    Foo = "Bar"
  }
}
