

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220923012346848908"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-220923012346848908"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  
resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh220923012346848908"
  web_pubsub_id = azurerm_web_pubsub.test.id
  event_handler {
    url_template       = "https://test.com/api/{hub}/{event}"
    user_event_pattern = "*"
    system_events      = ["connect", "connected"]

    auth {
      managed_identity_id = "12345678-9012-3456-7890-123456789012"
    }
  }
  anonymous_connections_enabled = true

  depends_on = [
    azurerm_web_pubsub.test
  ]
}
