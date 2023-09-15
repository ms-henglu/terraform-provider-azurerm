

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915023817078603"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-230915023817078603"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctest-mag-230915023817078603"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "test mag"
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "test" {
  name                = "acctest-isqr-230915023817078603"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"

  evaluation_frequency = "PT10M"
  window_duration      = "PT10M"
  scopes               = [azurerm_application_insights.test.id]
  severity             = 4
  criteria {
    query                   = <<-QUERY
      requests
        | summarize CountByCountry=count() by client_CountryOrRegion
      QUERY
    time_aggregation_method = "Maximum"
    threshold               = 17.5
    operator                = "LessThan"

    resource_id_column    = "client_CountryOrRegion"
    metric_measure_column = "CountByCountry"
    dimension {
      name     = "client_CountryOrRegion"
      operator = "Exclude"
      values   = ["123"]
    }
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = true
  workspace_alerts_storage_enabled = false
  description                      = "test sqr"
  display_name                     = "acctest-sqr"
  enabled                          = true
  query_time_range_override        = "PT1H"
  skip_query_validation            = true
  action {
    action_groups = [azurerm_monitor_action_group.test.id]
    custom_properties = {
      key  = "value"
      key2 = "value2"
    }
  }

  tags = {
    key  = "value"
    key2 = "value2"
  }
}
