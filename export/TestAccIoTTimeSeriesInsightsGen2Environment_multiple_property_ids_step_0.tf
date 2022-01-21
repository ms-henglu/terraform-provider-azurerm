
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-220121044622388627"
  location = "West Europe"
}
resource "azurerm_storage_account" "storage" {
  name                     = "acctestsatsiqyw2x"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_iot_time_series_insights_gen2_environment" "test" {
  name                = "acctest_tsie220121044622388627"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "L1"
  id_properties       = ["id", "secondId"]

  storage {
    name = azurerm_storage_account.storage.name
    key  = azurerm_storage_account.storage.primary_access_key
  }
}
