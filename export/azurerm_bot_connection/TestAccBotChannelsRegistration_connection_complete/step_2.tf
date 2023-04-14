

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020838377801"
  location = "West Europe"
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230414020838377801"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230414020838377801"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_bot_connection" "test" {
  name                  = "acctestBc230414020838377801"
  bot_name              = azurerm_bot_channels_registration.test.name
  location              = azurerm_bot_channels_registration.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "Salesforce"
  client_id             = azurerm_user_assigned_identity.test.client_id
  client_secret         = "32ea21cb-cb20-4df9-ad39-b55e985e9117"
  scopes                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}"

  parameters = {
    loginUri = "https://www.terraform.io"
  }
}
