


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072438571444"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsat7na0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst211013072438571444"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition211013072438571444"
  row_key       = "test_row211013072438571444"
  entity = {
    Foo = "Bar"
  }
}


resource "azurerm_storage_table_entity" "import" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition211013072438571444"
  row_key       = "test_row211013072438571444"
  entity = {
    Foo = "Bar"
  }
}
