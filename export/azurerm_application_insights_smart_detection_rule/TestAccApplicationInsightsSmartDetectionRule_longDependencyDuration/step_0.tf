
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033318113147"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231016033318113147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_smart_detection_rule" "test" {
  name                    = "Long dependency duration"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}
