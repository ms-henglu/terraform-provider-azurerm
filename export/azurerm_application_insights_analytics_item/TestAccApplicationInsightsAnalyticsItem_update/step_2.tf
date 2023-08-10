
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230810142901400396"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230810142901400396"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_analytics_item" "test" {
  name                    = "testquery"
  application_insights_id = azurerm_application_insights.test.id
  content                 = "requests #updated"
  scope                   = "shared"
  type                    = "query"
}
