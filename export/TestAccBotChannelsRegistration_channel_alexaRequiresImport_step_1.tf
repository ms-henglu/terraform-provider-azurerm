


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203013509447473"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf211203013509447473"
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
  skill_id            = "amzn1.ask.skill.34d280f7-ad9c-450d-84aa-d7773d06b430"
}


resource "azurerm_bot_channel_alexa" "import" {
  bot_name            = azurerm_bot_channel_alexa.test.bot_name
  location            = azurerm_bot_channel_alexa.test.location
  resource_group_name = azurerm_bot_channel_alexa.test.resource_group_name
  skill_id            = azurerm_bot_channel_alexa.test.skill_id
}
