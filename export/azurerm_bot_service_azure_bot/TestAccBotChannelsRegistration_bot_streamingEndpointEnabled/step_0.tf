
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071332643127"
  location = "West Europe"
}

resource "azurerm_bot_service_azure_bot" "test" {
  name                       = "acctestdf231218071332643127"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = "global"
  sku                        = "F0"
  microsoft_app_id           = data.azurerm_client_config.current.client_id
  streaming_endpoint_enabled = true
}
