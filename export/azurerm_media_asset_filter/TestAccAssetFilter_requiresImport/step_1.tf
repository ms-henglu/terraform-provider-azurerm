


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230825024911668782"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1f4lqk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaf4lqk"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}

resource "azurerm_media_asset" "test" {
  name                        = "test"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
}


resource "azurerm_media_asset_filter" "test" {
  name     = "Filter-1"
  asset_id = azurerm_media_asset.test.id
}


resource "azurerm_media_asset_filter" "import" {
  name     = azurerm_media_asset_filter.test.name
  asset_id = azurerm_media_asset.test.id
}
