
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025743223927"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestaccjiotp"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}