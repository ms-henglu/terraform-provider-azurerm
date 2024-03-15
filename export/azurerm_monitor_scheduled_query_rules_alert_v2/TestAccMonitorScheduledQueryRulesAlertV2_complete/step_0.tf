

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240315123545779591"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-240315123545779591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctest-mag-240315123545779591"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "test mag"
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "test" {
  name                = "acctest-isqr-240315123545779591"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"

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
    operator                = "GreaterThan"

    resource_id_column = "client_CountryOrRegion"
    dimension {
      name     = "client_CountryOrRegion"
      operator = "Include"
      values   = ["*"]
    }
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled           = false
  workspace_alerts_storage_enabled  = false
  description                       = "test sqr"
  display_name                      = "acctest-sqr"
  enabled                           = false
  mute_actions_after_alert_duration = "PT10M"
  query_time_range_override         = "PT10M"
  skip_query_validation             = false
  target_resource_types             = ["microsoft.insights/components"]
  action {
    action_groups = [azurerm_monitor_action_group.test.id]
    custom_properties = {
      key = "value"
    }
  }

  tags = {
    key = "value"
  }
}
