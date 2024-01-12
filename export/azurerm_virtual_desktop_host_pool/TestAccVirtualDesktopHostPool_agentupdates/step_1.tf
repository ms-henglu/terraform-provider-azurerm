
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktophp-240112224346450265"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHPx3148"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "BreadthFirst"
  scheduled_agent_updates {
    enabled                   = true
    use_session_host_timezone = true
    schedule {
      day_of_week = "Saturday"
      hour_of_day = 2
    }
    schedule {
      day_of_week = "Sunday"
      hour_of_day = 2
    }
  }
}
