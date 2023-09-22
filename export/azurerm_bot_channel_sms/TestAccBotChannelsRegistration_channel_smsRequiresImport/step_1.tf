


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
  name     = "acctestRG-230922053721317587"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230922053721317587"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_bot_channel_sms" "test" {
  bot_name                        = azurerm_bot_channels_registration.test.name
  location                        = azurerm_bot_channels_registration.test.location
  resource_group_name             = azurerm_resource_group.test.name
  sms_channel_account_security_id = "ARM_TEST_SMS_CHANNEL_ACCOUNT_SECURITY_ID"
  sms_channel_auth_token          = "ARM_TEST_SMS_CHANNEL_AUTH_TOKEN"
  phone_number                    = "ARM_TEST_PHONE_NUMBER"
}


resource "azurerm_bot_channel_sms" "import" {
  bot_name                        = azurerm_bot_channel_sms.test.bot_name
  location                        = azurerm_bot_channel_sms.test.location
  resource_group_name             = azurerm_bot_channel_sms.test.resource_group_name
  sms_channel_account_security_id = azurerm_bot_channel_sms.test.sms_channel_account_security_id
  sms_channel_auth_token          = azurerm_bot_channel_sms.test.sms_channel_auth_token
  phone_number                    = azurerm_bot_channel_sms.test.phone_number
}
