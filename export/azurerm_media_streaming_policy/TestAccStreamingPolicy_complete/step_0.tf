

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-231013043833300377"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa11m1bk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa1m1bk"
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


resource "azurerm_media_content_key_policy" "test" {
  name                        = "Policy-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  description                 = "My Policy Description"
  policy_option {
    name                            = "ClearKeyOption"
    clear_key_configuration_enabled = true
    token_restriction {
      issuer                      = "urn:issuer"
      audience                    = "urn:audience"
      token_type                  = "Swt"
      primary_symmetric_token_key = "AAAAAAAAAAAAAAAAAAAAAA=="
    }
  }
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

    clear_track {
      condition {
        property  = "FourCC"
        operation = "Equal"
        value     = "hev2"
      }
    }

    clear_track {
      condition {
        property  = "FourCC"
        operation = "Equal"
        value     = "hev1"
      }
    }

    default_content_key {
      label       = "aesDefaultKey"
      policy_name = azurerm_media_content_key_policy.test.name
    }

    content_key_to_track_mapping {
      label       = "aesKey"
      policy_name = azurerm_media_content_key_policy.test.name
      track {
        condition {
          property  = "FourCC"
          operation = "Equal"
          value     = "hev1"
        }
      }
    }

    drm_playready {
      custom_license_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/playready/{ContentKeyId}"
      custom_attributes                       = "PlayReady CustomAttributes"
    }
    drm_widevine_custom_license_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/widevine/{ContentKeyId}"
  }

  common_encryption_cbcs {
    default_content_key {
      label       = "aesDefaultKey"
      policy_name = azurerm_media_content_key_policy.test.name
    }
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

  envelope_encryption {
    default_content_key {
      label       = "aesDefaultKey"
      policy_name = azurerm_media_content_key_policy.test.name
    }
    custom_keys_acquisition_url_template = "https://contoso.com/{AssetAlternativeId}/envelope/{ContentKeyId}"
    enabled_protocols {
      dash             = true
      download         = false
      hls              = true
      smooth_streaming = true
    }
  }
}
