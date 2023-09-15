

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230915022829151332"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230915022829151332"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_analytics_item" "test" {
  name                    = "testquery"
  application_insights_id = azurerm_application_insights.test.id
  content                 = "requests #test"
  scope                   = "shared"
  type                    = "query"
}


resource "azurerm_application_insights_analytics_item" "import" {
  name                    = azurerm_application_insights_analytics_item.test.name
  application_insights_id = azurerm_application_insights_analytics_item.test.application_insights_id
  type                    = azurerm_application_insights_analytics_item.test.type
  scope                   = azurerm_application_insights_analytics_item.test.scope
  content                 = azurerm_application_insights_analytics_item.test.content
}
