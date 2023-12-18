
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071150960449"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231218071150960449"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "read_key" {
  name                    = "acctestappinsightsapikeyread-231218071150960449"
  application_insights_id = azurerm_application_insights.test.id
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
}

resource "azurerm_application_insights_api_key" "write_key" {
  name                    = "acctestappinsightsapikeywrite-231218071150960449"
  application_insights_id = azurerm_application_insights.test.id
  write_permissions       = ["annotations"]
}
