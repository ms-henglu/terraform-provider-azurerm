
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602031118024067"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-230602031118024067"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230602031118024067"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
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
    category_pattern          = ["connections", "messages"]
    event_pattern             = ["*"]
    hub_pattern               = ["hub1"]
    url_template              = "http://foo.com"
    user_assigned_identity_id = azurerm_user_assigned_identity.test.client_id
  }
}
  