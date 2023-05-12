

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011501869385"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa0mgkg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230512011501869385"
  storage_account_name = azurerm_storage_account.test.name
}


resource "azurerm_storage_table_entity" "test" {
  storage_account_name = azurerm_storage_account.test.name
  table_name           = azurerm_storage_table.test.name

  partition_key = "test_partition230512011501869385"
  row_key       = "test_row230512011501869385"
  entity = {
    Foo              = 123
    "Foo@odata.type" = "Edm.Int32"
    Test             = "Updated"
  }
}
