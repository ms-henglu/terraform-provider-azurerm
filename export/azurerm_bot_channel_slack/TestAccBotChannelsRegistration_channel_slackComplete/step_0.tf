

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
  name     = "acctestRG-230922060711297941"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230922060711297941"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_bot_channel_slack" "test" {
  bot_name            = azurerm_bot_channels_registration.test.name
  location            = azurerm_bot_channels_registration.test.location
  resource_group_name = azurerm_resource_group.test.name
  client_id           = "ARM_TEST_SLACK_CLIENT_ID"
  client_secret       = "ARM_TEST_SLACK_CLIENT_SECRET"
  verification_token  = "ARM_TEST_SLACK_VERIFICATION_TOKEN"
  signing_secret      = "ARM_TEST_SLACK_SIGNING_SECRET"
  landing_page_url    = "http://example.com"
}
