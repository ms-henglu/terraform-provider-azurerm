

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024302568777"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalhx17"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230915024302568777"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition230915024302568777"
  row_key       = "test_row230915024302568777"
  entity = {
    Foo              = 123
    "Foo@odata.type" = "Edm.Int32"
    Test             = "Updated"
  }
}
