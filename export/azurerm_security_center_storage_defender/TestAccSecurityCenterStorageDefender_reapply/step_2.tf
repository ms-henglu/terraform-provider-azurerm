
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240112225212180570"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestaccal0ju"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}