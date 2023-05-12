


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010311021984"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230512010311021984"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_cognitive_account" "test" {
  name                = "acctest-cogacct-230512010311021984"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}


resource "azurerm_bot_channel_direct_line_speech" "test" {
  bot_name                     = azurerm_bot_channels_registration.test.name
  location                     = azurerm_bot_channels_registration.test.location
  resource_group_name          = azurerm_resource_group.test.name
  cognitive_service_location   = azurerm_cognitive_account.test.location
  cognitive_service_access_key = azurerm_cognitive_account.test.primary_access_key
}
