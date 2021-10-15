
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014837495986"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-211015014837495986"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  features {
    flag  = "ServiceMode"
    value = "Serverless"
  }

  features {
    flag  = "EnableConnectivityLogs"
    value = "False"
  }

  features {
    flag  = "EnableMessagingLogs"
    value = "False"
  }

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
  