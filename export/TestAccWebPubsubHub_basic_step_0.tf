

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220324164017522368"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-220324164017522368"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh220324164017522368"
  web_pubsub_id = azurerm_web_pubsub.test.id

  event_handler {
    url_template       = "https://test.com/api/{hub}/{event}"
    user_event_pattern = "*"
    system_events      = ["connect", "connected"]
  }
}
