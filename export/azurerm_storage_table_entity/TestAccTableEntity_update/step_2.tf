

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072636528813"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsae78v4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst231218072636528813"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition231218072636528813"
  row_key       = "test_row231218072636528813"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
