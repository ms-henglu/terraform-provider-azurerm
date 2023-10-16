

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-231016034308281478"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1rx24e"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsarx24e"
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
    relative_priority = "High"
    on_error_action   = "ContinueJob"
    builtin_preset {
      preset_name = "AACGoodQualityAudio"
      preset_configuration {
        complexity                    = "Balanced"
        interleave_output             = "NonInterleavedOutput"
        key_frame_interval_in_seconds = 123122.5
        max_bitrate_bps               = 300000
        max_height                    = 480
        max_layers                    = 14
        min_bitrate_bps               = 200000
        min_height                    = 360
      }
    }
  }

  output {
    relative_priority = "High"
    on_error_action   = "StopProcessingJob"
    audio_analyzer_preset {
      audio_language      = "ar-SA"
      audio_analysis_mode = "Basic"
      experimental_options = {
        env = "test"
      }
    }
  }

  output {
    relative_priority = "Low"
    on_error_action   = "StopProcessingJob"
    face_detector_preset {
      analysis_resolution = "StandardDefinition"
      blur_type           = "Med"
      face_redactor_mode  = "Combined"
      experimental_options = {
        env = "test"
      }
    }
  }

  output {
    relative_priority = "Normal"
    on_error_action   = "StopProcessingJob"
    video_analyzer_preset {
      audio_language      = "en-US"
      audio_analysis_mode = "Basic"
      insights_type       = "AllInsights"
      experimental_options = {
        env = "test"
      }
    }
  }

  output {
    relative_priority = "Low"
    on_error_action   = "ContinueJob"
    custom_preset {
      codec {
        aac_audio {
          bitrate       = 128000
          channels      = 2
          sampling_rate = 48000
          profile       = "AacLc"
        }
      }

      codec {
        copy_audio {
          label = "test"
        }
      }

      codec {
        copy_video {
          label = "test"
        }
      }

      codec {
        h264_video {
          key_frame_interval             = "PT1S"
          stretch_mode                   = "AutoSize"
          sync_mode                      = "Auto"
          scene_change_detection_enabled = false
          rate_control_mode              = "ABR"
          complexity                     = "Quality"
          layer {
            width                    = "64"
            height                   = "64"
            bitrate                  = 1045000
            max_bitrate              = 1045000
            b_frames                 = 3
            slices                   = 0
            adaptive_b_frame_enabled = true
            profile                  = "Auto"
            level                    = "auto"
            buffer_window            = "PT5S"
            reference_frames         = 4
            crf                      = 23
            entropy_mode             = "Cabac"
          }
          layer {
            width                    = "64"
            height                   = "64"
            bitrate                  = 1000
            max_bitrate              = 1000
            b_frames                 = 3
            frame_rate               = "32"
            slices                   = 1
            adaptive_b_frame_enabled = true
            profile                  = "High444"
            level                    = "auto"
            buffer_window            = "PT5S"
            reference_frames         = 4
            crf                      = 23
            entropy_mode             = "Cavlc"
          }
        }
      }

      codec {
        h265_video {
          key_frame_interval             = "PT2S"
          stretch_mode                   = "AutoSize"
          sync_mode                      = "Auto"
          scene_change_detection_enabled = false
          complexity                     = "Speed"
          layer {
            width                    = "64"
            height                   = "64"
            bitrate                  = 1045000
            max_bitrate              = 1045000
            b_frames                 = 3
            slices                   = 5
            adaptive_b_frame_enabled = true
            profile                  = "Auto"
            label                    = "test"
            level                    = "auto"
            buffer_window            = "PT5S"
            frame_rate               = "32"
            reference_frames         = 4
            crf                      = 23
          }
        }
      }

      codec {
        jpg_image {
          stretch_mode  = "AutoSize"
          sync_mode     = "Auto"
          start         = "10"
          range         = "100%"
          sprite_column = 1
          step          = "10"
          layer {
            quality = 70
            height  = "180"
            label   = "test"
            width   = "120"
          }
        }
      }

      codec {
        png_image {
          stretch_mode = "AutoSize"
          sync_mode    = "Auto"
          start        = "{Best}"
          range        = "80"
          step         = "10"
          layer {
            height = "180"
            label  = "test"
            width  = "120"
          }
        }
      }

      format {
        jpg {
          filename_pattern = "test{Basename}"
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

      format {
        png {
          filename_pattern = "test{Basename}"
        }
      }

      format {
        transport_stream {
          filename_pattern = "test{Bitrate}"
          output_file {
            labels = ["prod"]
          }
        }
      }

      experimental_options = {
        env = "prod"
      }

      filter {
        crop_rectangle {
          height = "240"
          left   = "30"
          top    = "360"
          width  = "70"
        }
        deinterlace {
          parity = "TopFieldFirst"
          mode   = "AutoPixelAdaptive"
        }
        fade_in {
          duration   = "PT5S"
          fade_color = "0xFF0000"
          start      = "10"
        }
        fade_out {
          duration   = "90%"
          fade_color = "#FF0C7B"
          start      = "10%"
        }
        rotation = "Auto"
        overlay {
          audio {
            input_label       = "label.jpg"
            start             = "PT5S"
            end               = "PT30S"
            fade_in_duration  = "PT1S"
            fade_out_duration = "PT2S"
            audio_gain_level  = 1.0
          }
        }
        overlay {
          video {
            input_label       = "label.jpg"
            start             = "PT5S"
            end               = "PT30S"
            fade_in_duration  = "PT1S"
            fade_out_duration = "PT2S"
            audio_gain_level  = 1.0
            opacity           = 1.0
            position {
              height = "180"
              left   = "20"
              top    = "240"
              width  = "140"
            }
            crop_rectangle {
              height = "240"
              left   = "30"
              top    = "360"
              width  = "70"
            }
          }
        }
      }
    }
  }
}
