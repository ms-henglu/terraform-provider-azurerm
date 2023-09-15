
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023005307845"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230915023005307845"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "test" {
  name                    = "acctestappinsightsapikey-230915023005307845"
  application_insights_id = azurerm_application_insights.test.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
}

resource "azurerm_bot_service_azure_bot" "test" {
  name                         = "acctestdf230915023005307845"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "global"
  microsoft_app_id             = data.azurerm_client_config.current.client_id
  sku                          = "F0"
  local_authentication_enabled = false

  endpoint                              = "https://example.com"
  developer_app_insights_api_key        = azurerm_application_insights_api_key.test.api_key
  developer_app_insights_application_id = azurerm_application_insights.test.app_id

  tags = {
    environment = "test"
  }
}
