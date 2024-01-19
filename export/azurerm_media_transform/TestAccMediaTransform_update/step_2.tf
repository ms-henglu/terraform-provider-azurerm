

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240119025405156596"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1q3eyu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaq3eyu"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}


resource "azurerm_media_transform" "test" {
  name                        = "Transform-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  description                 = "Transform description"
  output {
    builtin_preset {
      preset_name = "AACGoodQualityAudio"
      preset_configuration {
        complexity = "Balanced"
      }
    }
  }

  output {
    audio_analyzer_preset {
      audio_language = "ar-SA"
    }
  }

  output {
    relative_priority = "Low"
    on_error_action   = "ContinueJob"
    custom_preset {
      codec {
        aac_audio {
          bitrate = 128000
        }
      }

      codec {
        h264_video {
          layer {
            bitrate = 1045000
          }
          layer {
            bitrate = 1000
          }
        }
      }

      codec {
        h265_video {
          complexity = "Speed"
          layer {
            bitrate = 1045000
          }
        }
      }

      format {
        mp4 {
          filename_pattern = "test{Bitrate}"
          output_file {
            labels = ["test", "ppe"]
          }
        }
      }

      filter {
        crop_rectangle {
          height = "240"
        }
        deinterlace {
          parity = "TopFieldFirst"
        }
        fade_in {
          duration   = "PT5S"
          fade_color = "0xFF0000"
        }
        rotation = "Auto"
        overlay {
          audio {
            input_label = "label.jpg"
          }
        }
        overlay {
          video {
            input_label = "test.wav"
            position {
              width = "140"
            }
            crop_rectangle {
              width = "70"
            }
          }
        }
      }
    }
  }
}
