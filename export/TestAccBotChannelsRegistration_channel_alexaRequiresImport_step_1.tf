


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
  name     = "acctestRG-220712042012208228"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf220712042012208228"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_bot_channel_alexa" "test" {
  bot_name            = azurerm_bot_channels_registration.test.name
  location            = azurerm_bot_channels_registration.test.location
  resource_group_name = azurerm_resource_group.test.name
  skill_id            = "amzn1.ask.skill.71aef6f7-e7f8-4b6b-9d52-4bbe776076e2"
}


resource "azurerm_bot_channel_alexa" "import" {
  bot_name            = azurerm_bot_channel_alexa.test.bot_name
  location            = azurerm_bot_channel_alexa.test.location
  resource_group_name = azurerm_bot_channel_alexa.test.resource_group_name
  skill_id            = azurerm_bot_channel_alexa.test.skill_id
}
