
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231016034644397618"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestaccakq3o"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}