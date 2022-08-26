

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003348653772"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa9edvl"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220826003348653772"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition220826003348653772"
  row_key       = "test_row220826003348653772"
  entity = {
    Foo              = 123
    "Foo@odata.type" = "Edm.Int32"
    Test             = "Updated"
  }
}
