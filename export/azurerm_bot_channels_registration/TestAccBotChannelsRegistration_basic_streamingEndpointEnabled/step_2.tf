
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
  name     = "acctestRG-240311031452440382"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                       = "acctestdf240311031452440382"
  location                   = "global"
  resource_group_name        = azurerm_resource_group.test.name
  sku                        = "F0"
  microsoft_app_id           = data.azurerm_client_config.current.client_id
  streaming_endpoint_enabled = false
}
