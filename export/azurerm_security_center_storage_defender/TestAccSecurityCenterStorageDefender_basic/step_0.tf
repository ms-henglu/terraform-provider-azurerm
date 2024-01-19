

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025743221278"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestacc03gh9"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_security_center_storage_defender" "test" {
  storage_account_id = azurerm_storage_account.test.id
}
