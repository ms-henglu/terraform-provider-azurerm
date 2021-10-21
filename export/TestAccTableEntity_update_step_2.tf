

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235556892699"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsazjgpg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst211021235556892699"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition211021235556892699"
  row_key       = "test_row211021235556892699"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
