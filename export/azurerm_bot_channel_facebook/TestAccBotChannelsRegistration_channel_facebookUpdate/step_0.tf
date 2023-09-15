

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
  name     = "acctestRG-230915023005302332"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230915023005302332"
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
  facebook_application_id     = "ARM_TEST_FACEBOOK_APPLICATION_ID"
  facebook_application_secret = "ARM_TEST_FACEBOOK_APPLICATION_SECRET"

  page {
    id           = "ARM_TEST_PAGE_ID"
    access_token = "ARM_TEST_PAGE_ACCESS_TOKEN"
  }
}
