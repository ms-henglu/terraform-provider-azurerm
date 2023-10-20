

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-231020041911221074"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-231020041911221074"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  

resource "azurerm_user_assigned_identity" "test1" {
  name                = "acctest-uai1-231020041911221074"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh231020041911221074"
  web_pubsub_id = azurerm_web_pubsub.test.id
  event_handler {
    url_template       = "https://test.com/api/{testhub}/{testevent1}"
    user_event_pattern = "event1, event2"
    system_events      = ["disconnected", "connect", "connected"]
    auth {
      managed_identity_id = azurerm_user_assigned_identity.test1.id
    }
  }
}
