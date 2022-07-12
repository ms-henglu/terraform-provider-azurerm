

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220712042903459251"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220712042903459251"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-220712042903459251"
    ttl           = 30
  }

  monitor_config {
    expected_status_code_ranges = [
      "302-304",
    ]

    custom_header {
      name  = "foo2"
      value = "bar2"
    }

    protocol = "HTTPS"
    port     = 442
    path     = "/"

    interval_in_seconds          = 30
    timeout_in_seconds           = 6
    tolerated_number_of_failures = 3
  }

  tags = {
    Environment = "staging"
  }
}


resource "azurerm_traffic_manager_external_endpoint" "test" {
  name       = "acctestend-external220712042903459251"
  profile_id = azurerm_traffic_manager_profile.test.id
  target     = "pluginsdk.io"
  weight     = 100
}

