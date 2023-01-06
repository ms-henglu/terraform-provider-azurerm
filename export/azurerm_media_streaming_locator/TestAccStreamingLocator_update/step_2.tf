

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230106031711769603"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1b67kr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsab67kr"
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
  name                        = "Job-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  streaming_policy_name       = "Predefined_DownloadOnly"
  asset_name                  = azurerm_media_asset.test.name
  start_time                  = "2018-03-01T00:00:00Z"
  end_time                    = "2028-12-31T23:59:59Z"
  streaming_locator_id        = "90000000-0000-0000-0000-000000000000"
  alternative_media_id        = "my-Alternate-MediaID"
}
