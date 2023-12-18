
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231218072510967748"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestaccgx4uu"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}