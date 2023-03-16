

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230316222334805260"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-230316222334805260"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_user_assigned_identity" "test1" {
  name                = "acctest-uai1-230316222334805260"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh230316222334805260"
  web_pubsub_id = azurerm_web_pubsub.test.id
  event_handler {
    url_template       = "https://test.com/api/{hub1}/{event2}"
    user_event_pattern = "*"
    system_events      = ["connect", "connected"]
  }
  event_handler {
    url_template       = "https://test.com/api/{hub2}/{event1}"
    user_event_pattern = "event1, event2"
    system_events      = ["connected"]
    auth {
      managed_identity_id = azurerm_user_assigned_identity.test1.id
    }
  }
}
