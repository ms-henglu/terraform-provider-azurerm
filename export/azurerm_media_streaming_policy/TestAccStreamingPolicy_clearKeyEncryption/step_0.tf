

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230915023800061689"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1flb1z"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaflb1z"
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
  name                            = "Policy-1"
  resource_group_name             = azurerm_resource_group.test.name
  media_services_account_name     = azurerm_media_services_account.test.name
  default_content_key_policy_name = azurerm_media_content_key_policy.test.name
  common_encryption_cenc {
    default_content_key {
      label = "aesDefaultKey"
    }

    clear_track {
      condition {
        property  = "FourCC"
        operation = "Equal"
        value     = "hev1"
      }
    }

    enabled_protocols {
      download         = false
      dash             = true
      hls              = false
      smooth_streaming = true
    }

    clear_key_encryption {
      custom_keys_acquisition_url_template = "https://contoso.com/{AlternativeMediaId}/clearkey/"
    }
  }
}
