

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025909551425"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsae0jpe"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst240119025909551425"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition240119025909551425"
  row_key       = "test_row240119025909551425"
  entity = {
    Foo              = 123
    "Foo@odata.type" = "Edm.Int32"
    Test             = "Updated"
  }
}
