

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024134725251"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230825024134725251"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id
}


resource "azurerm_bot_connection" "test" {
  name                  = "acctestBc230825024134725251"
  bot_name              = azurerm_bot_channels_registration.test.name
  location              = azurerm_bot_channels_registration.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "box"
  client_id             = data.azurerm_client_config.current.client_id
  client_secret         = "86546868-e7ed-429f-b0e5-3a1caea7db64"
}
