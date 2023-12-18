


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231218072510960918"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestacciecnp"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_security_center_storage_defender" "test" {
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_security_center_storage_defender" "import" {
  storage_account_id = azurerm_security_center_storage_defender.test.id
}
