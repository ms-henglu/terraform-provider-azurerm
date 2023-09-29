


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230929065312840767"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-230929065312840767"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctest-mag-230929065312840767"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "test mag"
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "test" {
  name                 = "acctest-isqr-230929065312840767"
  resource_group_name  = azurerm_resource_group.test.name
  location             = "West Europe"
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_application_insights.test.id]
  severity             = 3
  criteria {
    query                   = <<-QUERY
      requests
	    | summarize CountByCountry=count() by client_CountryOrRegion
	  QUERY
    time_aggregation_method = "Count"
    threshold               = 5.0
    operator                = "Equal"
  }
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "import" {
  name                 = azurerm_monitor_scheduled_query_rules_alert_v2.test.name
  resource_group_name  = azurerm_resource_group.test.name
  location             = "West Europe"
  evaluation_frequency = azurerm_monitor_scheduled_query_rules_alert_v2.test.evaluation_frequency
  window_duration      = azurerm_monitor_scheduled_query_rules_alert_v2.test.window_duration
  scopes               = azurerm_monitor_scheduled_query_rules_alert_v2.test.scopes
  severity             = azurerm_monitor_scheduled_query_rules_alert_v2.test.severity
  criteria {
    query                   = azurerm_monitor_scheduled_query_rules_alert_v2.test.criteria.0.query
    time_aggregation_method = azurerm_monitor_scheduled_query_rules_alert_v2.test.criteria.0.time_aggregation_method
    threshold               = azurerm_monitor_scheduled_query_rules_alert_v2.test.criteria.0.threshold
    operator                = azurerm_monitor_scheduled_query_rules_alert_v2.test.criteria.0.operator
  }
}
