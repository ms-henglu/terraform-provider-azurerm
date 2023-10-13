



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
  name     = "acctestRG-231013043032255398"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf231013043032255398"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_cognitive_account" "test" {
  name                = "acctest-cogacct-231013043032255398"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}


resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-dls-231013043032255398"
  location = "West US 2"
}

resource "azurerm_cognitive_account" "test2" {
  name                = "acctest-cogacct-231013043032255398"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}


resource "azurerm_bot_channel_direct_line_speech" "test" {
  bot_name                     = azurerm_bot_channels_registration.test.name
  location                     = azurerm_bot_channels_registration.test.location
  resource_group_name          = azurerm_resource_group.test.name
  cognitive_account_id         = azurerm_cognitive_account.test2.id
  cognitive_service_location   = azurerm_cognitive_account.test2.location
  cognitive_service_access_key = azurerm_cognitive_account.test2.primary_access_key
  custom_speech_model_id       = "cf7a4202-9be3-4195-9619-5a747260626d"
  custom_voice_deployment_id   = "b815f623-c217-4327-b765-f6e0fd7dceef"
}
