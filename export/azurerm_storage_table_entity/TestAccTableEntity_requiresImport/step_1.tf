


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034824821897"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsav66b1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst231016034824821897"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition231016034824821897"
  row_key       = "test_row231016034824821897"
  entity = {
    Foo = "Bar"
  }
}


resource "azurerm_storage_table_entity" "import" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition231016034824821897"
  row_key       = "test_row231016034824821897"
  entity = {
    Foo = "Bar"
  }
}
