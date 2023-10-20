 

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
  name     = "acctestRG-231020040644832494"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf231020040644832494"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  tags = {
    environment = "production"
  }
}


resource "azurerm_bot_channel_directline" "test" {
  bot_name            = "${azurerm_bot_channels_registration.test.name}"
  location            = "${azurerm_bot_channels_registration.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  site {
    name                            = "test1"
    enabled                         = true
    v1_allowed                      = true
    v3_allowed                      = true
    enhanced_authentication_enabled = true
    trusted_origins                 = ["https://example.com"]
    user_upload_enabled             = false
    endpoint_parameters_enabled     = true
    storage_enabled                 = false
  }

  site {
    name                            = "test2"
    enabled                         = true
    enhanced_authentication_enabled = false
    user_upload_enabled             = true
    endpoint_parameters_enabled     = false
    storage_enabled                 = true
  }
}
