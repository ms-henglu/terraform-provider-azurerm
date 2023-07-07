

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230707004325021413"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa13b48b"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa3b48b"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}


resource "azurerm_media_asset" "test" {
  name                        = "Asset-Content1"
  description                 = "Asset description"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  storage_account_name        = azurerm_storage_account.test.name
  alternate_id                = "Asset-alternateid"
  container                   = "asset-container"
}
