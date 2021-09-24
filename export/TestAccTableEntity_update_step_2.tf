

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004925897746"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaz72u4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst210924004925897746"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition210924004925897746"
  row_key       = "test_row210924004925897746"
  entity = {
    Foo  = "Bar"
    Test = "Updated"
  }
}
