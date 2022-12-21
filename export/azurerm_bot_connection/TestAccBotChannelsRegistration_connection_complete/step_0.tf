

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204016933015"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf221221204016933015"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id
}


resource "azurerm_bot_connection" "test" {
  name                  = "acctestBc221221204016933015"
  bot_name              = azurerm_bot_channels_registration.test.name
  location              = azurerm_bot_channels_registration.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "Salesforce"
  client_id             = data.azurerm_client_config.current.client_id
  client_secret         = "60a97b1d-0894-4c5a-9968-7d1d29d77aed"
  scopes                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"

  parameters = {
    loginUri = "https://www.google.com"
  }
}
