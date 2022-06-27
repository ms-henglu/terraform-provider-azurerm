


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131911682475"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalq6z4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220627131911682475"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220627131911682475"
  row_key       = "test_row220627131911682475"
  entity = {
    Foo = "Bar"
  }
}


resource "azurerm_storage_table_entity" "import" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220627131911682475"
  row_key       = "test_row220627131911682475"
  entity = {
    Foo = "Bar"
  }
}
