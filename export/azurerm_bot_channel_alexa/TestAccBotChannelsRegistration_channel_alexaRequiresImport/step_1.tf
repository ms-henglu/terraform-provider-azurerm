


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
  name     = "acctestRG-230721014607914253"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230721014607914253"
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
  skill_id            = "amzn1.ask.skill.c22a581c-fb19-4eea-8699-2cab195502f2"
}


resource "azurerm_bot_channel_alexa" "import" {
  bot_name            = azurerm_bot_channel_alexa.test.bot_name
  location            = azurerm_bot_channel_alexa.test.location
  resource_group_name = azurerm_bot_channel_alexa.test.resource_group_name
  skill_id            = azurerm_bot_channel_alexa.test.skill_id
}
