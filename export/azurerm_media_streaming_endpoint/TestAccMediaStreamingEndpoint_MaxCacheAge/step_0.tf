

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240112224839683488"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1fqmfz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_media_services_account" "test" {
  name                = "acctestmsafqmfz"
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
  access_control {
    ip_allow {
      name    = "AllowedIP"
      address = "192.168.1.1"
    }

    ip_allow {
      name    = "AnotherIp"
      address = "192.168.1.2"
    }

    akamai_signature_header_authentication_key {
      identifier = "id1"
      expiration = "2030-12-31T16:00:00Z"
      base64_key = "dGVzdGlkMQ=="
    }

    akamai_signature_header_authentication_key {
      identifier = "id2"
      expiration = "2032-01-28T16:00:00Z"
      base64_key = "dGVzdGlkMQ=="
    }
  }
  max_cache_age_seconds = 60

}
