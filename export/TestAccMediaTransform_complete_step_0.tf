

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-210917031931294910"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa17iwtk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsa7iwtk"
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
    }
  }

  output {
    relative_priority = "High"
    on_error_action   = "StopProcessingJob"
    audio_analyzer_preset {
      audio_language      = "en-US"
      audio_analysis_mode = "Basic"
    }
  }

  output {
    relative_priority = "Low"
    on_error_action   = "StopProcessingJob"
    face_detector_preset {
      analysis_resolution = "StandardDefinition"
    }
  }

  output {
    relative_priority = "Normal"
    on_error_action   = "StopProcessingJob"
    video_analyzer_preset {
      audio_language      = "en-US"
      audio_analysis_mode = "Basic"
      insights_type       = "AllInsights"
    }
  }
}
