

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240105064223037960"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-ai-240105064223037960"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctest-mag-240105064223037960"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "test mag"
}


resource "azurerm_monitor_scheduled_query_rules_alert_v2" "test" {
  name                 = "acctest-isqr-240105064223037960"
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
