

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071346362509"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaa4hu6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220218071346362509"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220218071346362509"
  row_key       = "test_row220218071346362509"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
