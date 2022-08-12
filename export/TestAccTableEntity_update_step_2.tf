

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015838114421"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsak88xc"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220812015838114421"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220812015838114421"
  row_key       = "test_row220812015838114421"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
