

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
  name     = "acctestRG-240315122425938962"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf240315122425938962"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_bot_channel_facebook" "test" {
  bot_name                    = azurerm_bot_channels_registration.test.name
  location                    = azurerm_bot_channels_registration.test.location
  resource_group_name         = azurerm_resource_group.test.name
  facebook_application_id     = "ARM_TEST_FACEBOOK_APPLICATION_ID2"
  facebook_application_secret = "ARM_TEST_FACEBOOK_APPLICATION_SECRET2"

  page {
    id           = "ARM_TEST_PAGE_ID2"
    access_token = "ARM_TEST_PAGE_ACCESS_TOKEN2"
  }
}
