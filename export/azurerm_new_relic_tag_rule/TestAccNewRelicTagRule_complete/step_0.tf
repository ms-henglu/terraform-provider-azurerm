
provider "azurerm" {
  features {}
}
			
resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112225008962530"
  location = "West Europe"
}

resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-240112225008962530"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  plan {
    effective_date = "2024-01-15T00:00:00Z"
  }

  user {
    email        = "672d9312-65a7-484c-870d-94584850a423@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_new_relic_tag_rule" "test" {
  monitor_id                         = azurerm_new_relic_monitor.test.id
  azure_active_directory_log_enabled = true
  activity_log_enabled               = true
  metric_enabled                     = true
  subscription_log_enabled           = true

  log_tag_filter {
    name   = "log1"
    action = "Include"
    value  = "log1"
  }

  log_tag_filter {
    name   = "log2"
    action = "Exclude"
    value  = ""
  }

  metric_tag_filter {
    name   = "metric1"
    action = "Include"
    value  = "metric1"
  }

  metric_tag_filter {
    name   = "metric2"
    action = "Exclude"
    value  = ""
  }
}
