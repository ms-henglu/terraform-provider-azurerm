
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022829151215"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230915022829151215"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "test" {
  name                    = "acctestappinsightsapikey-230915022829151215"
  application_insights_id = azurerm_application_insights.test.id
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
  write_permissions       = ["annotations"]
}
