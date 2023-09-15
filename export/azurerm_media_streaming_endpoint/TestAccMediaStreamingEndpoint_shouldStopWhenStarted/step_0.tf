

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230915023800069197"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "acctestsa173e67"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa73e67"
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
  tags = {
    env = "test"
  }
}
