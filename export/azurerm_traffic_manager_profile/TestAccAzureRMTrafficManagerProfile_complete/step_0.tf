

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230922062059852677"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-230922062059852677"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "acctest-tmp-230922062059852677"
    ttl           = 30
  }

  monitor_config {
    expected_status_code_ranges = [
      "100-101",
      "301-303",
    ]

    custom_header {
      name  = "foo"
      value = "bar"
    }

    protocol = "TCP"
    port     = 777

    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 6
  }

  tags = {
    Environment = "Production"
    cost_center = "acctest"
  }
}
