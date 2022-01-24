

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124122741000241"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsahoh9q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220124122741000241"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220124122741000241"
  row_key       = "test_row220124122741000241"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
