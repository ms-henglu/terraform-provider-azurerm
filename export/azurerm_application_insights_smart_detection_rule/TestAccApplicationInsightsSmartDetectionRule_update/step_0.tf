
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313020708299264"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230313020708299264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_smart_detection_rule" "test" {
  name                    = "Slow page load time"
  application_insights_id = azurerm_application_insights.test.id
  enabled                 = false
}
