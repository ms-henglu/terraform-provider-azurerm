


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-221221204554670076"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1dcfpr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsadcfpr"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}


resource "azurerm_media_live_event" "test" {
  name                        = "Event-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  location                    = azurerm_resource_group.test.location

  input {
    streaming_protocol          = "RTMP"
    key_frame_interval_duration = "PT6S"
    ip_access_control_allow {
      name                 = "AllowAll"
      address              = "0.0.0.0"
      subnet_prefix_length = 0
    }
  }
}


resource "azurerm_media_live_event" "import" {
  name                        = azurerm_media_live_event.test.name
  resource_group_name         = azurerm_media_live_event.test.resource_group_name
  media_services_account_name = azurerm_media_live_event.test.media_services_account_name
  location                    = azurerm_resource_group.test.location

  input {
    streaming_protocol          = "RTMP"
    key_frame_interval_duration = "PT6S"
    ip_access_control_allow {
      name                 = "AllowAll"
      address              = "0.0.0.0"
      subnet_prefix_length = 0
    }
  }
}
