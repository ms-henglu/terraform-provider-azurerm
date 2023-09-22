
provider "azurerm" {
  features {}
}
			
resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922054633795037"
  location = "West Europe"
}

resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-230922054633795037"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  plan {
    effective_date = "2023-09-25T00:00:00Z"
  }

  user {
    email        = "f0ff47c3-3aed-45b0-b239-260d9625045a@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_new_relic_tag_rule" "test" {
  monitor_id                         = azurerm_new_relic_monitor.test.id
  azure_active_directory_log_enabled = false
  activity_log_enabled               = false
  metric_enabled                     = false
  subscription_log_enabled           = false

  log_tag_filter {
    name   = "log2"
    action = "Exclude"
    value  = ""
  }

  log_tag_filter {
    name   = "log1"
    action = "Include"
    value  = "log1"
  }

  metric_tag_filter {
    name   = "metric1"
    action = "Exclude"
    value  = ""
  }

  metric_tag_filter {
    name   = "metric2"
    action = "Include"
    value  = "metric1"
  }
}
