

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-211015014511770976"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1qxxvk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaqxxvk"
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


resource "azurerm_media_streaming_policy" "test" {
  name                        = "Policy-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  common_encryption_cenc {
    enabled_protocols {
      download         = false
      dash             = true
      hls              = false
      smooth_streaming = false
    }
    drm_playready {
      custom_license_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/playready/{ContentKeyId}"
      custom_attributes                       = "PlayReady CustomAttributes"
    }
    drm_widevine_custom_license_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/widevine/{ContentKeyId}"
  }

  common_encryption_cbcs {
    enabled_protocols {
      download         = false
      dash             = true
      hls              = false
      smooth_streaming = false
    }
    drm_fairplay {
      custom_license_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/fairplay/{ContentKeyId}"
      allow_persistent_license                = true
    }
  }
}

