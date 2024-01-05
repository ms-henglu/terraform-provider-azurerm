

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240105061138957424"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1g2ib3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsag2ib3"
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
  description                 = "Updated Description"

  input {
    streaming_protocol = "RTMP"
    ip_access_control_allow {
      name                 = "Test"
      address              = "0.0.0.0"
      subnet_prefix_length = 4
    }
  }

  encoding {
    type               = "Standard"
    preset_name        = "Default720p"
    stretch_mode       = "AutoSize"
    key_frame_interval = "PT2S"
  }

  preview {
    ip_access_control_allow {
      name                 = "Allow"
      address              = "0.0.0.0"
      subnet_prefix_length = 4
    }
  }

  use_static_hostname     = true
  hostname_prefix         = "special-event-update"
  stream_options          = ["LowLatency"]
  transcription_languages = ["en-GB"]

  tags = {
    env = "test"
  }
}
