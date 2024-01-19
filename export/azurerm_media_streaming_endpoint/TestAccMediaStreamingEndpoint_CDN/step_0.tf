

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240119025405131509"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1n0etf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_media_services_account" "test" {
  name                = "acctestmsan0etf"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}

resource "azurerm_media_streaming_endpoint" "test" {
  name                        = "endpoint1"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  media_services_account_name = azurerm_media_services_account.test.name
  scale_units                 = 1
  cdn_enabled                 = true
  cdn_provider                = "StandardVerizon"
  cdn_profile                 = "MyCDNProfile"
}
