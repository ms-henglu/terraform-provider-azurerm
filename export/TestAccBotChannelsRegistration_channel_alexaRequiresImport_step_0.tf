

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
  name     = "acctestRG-211217034952652615"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf211217034952652615"
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
  skill_id            = "amzn1.ask.skill.c9845572-a572-4173-acb2-b68205050b43"
}
