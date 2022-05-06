

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-220506010003049675"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1r4v9x"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsar4v9x"
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
  output {
    relative_priority = "High"
    on_error_action   = "ContinueJob"
    builtin_preset {
      preset_name = "AACGoodQualityAudio"
    }
  }
}
