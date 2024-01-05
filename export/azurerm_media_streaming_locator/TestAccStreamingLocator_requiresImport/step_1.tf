


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240105064206674135"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1ovpqf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaovpqf"
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


resource "azurerm_media_streaming_locator" "test" {
  name                        = "Locator-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  streaming_policy_name       = "Predefined_ClearStreamingOnly"
  asset_name                  = azurerm_media_asset.test.name
}


resource "azurerm_media_streaming_locator" "import" {
  name                        = azurerm_media_streaming_locator.test.name
  resource_group_name         = azurerm_media_streaming_locator.test.resource_group_name
  media_services_account_name = azurerm_media_streaming_locator.test.media_services_account_name
  streaming_policy_name       = "Predefined_ClearStreamingOnly"
  asset_name                  = azurerm_media_asset.test.name
}
