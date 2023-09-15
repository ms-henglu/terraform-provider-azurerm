
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024226757684"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230915024226757684"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }

  service_mode              = "Serverless"
  connectivity_logs_enabled = false
  messaging_logs_enabled    = false

  upstream_endpoint {
    category_pattern = ["*"]
    event_pattern    = ["*"]
    hub_pattern      = ["*"]
    url_template     = "http://foo.com/{hub}/api/{category}/{event}"
  }

  upstream_endpoint {
    category_pattern = ["connections", "messages"]
    event_pattern    = ["*"]
    hub_pattern      = ["hub1"]
    url_template     = "http://foo.com"
  }

  upstream_endpoint {
    category_pattern = ["*"]
    event_pattern    = ["connect", "disconnect"]
    hub_pattern      = ["hub1", "hub2"]
    url_template     = "http://foo3.com"
  }

  upstream_endpoint {
    category_pattern = ["connections"]
    event_pattern    = ["disconnect"]
    hub_pattern      = ["*"]
    url_template     = "http://foo4.com"
  }
}
  