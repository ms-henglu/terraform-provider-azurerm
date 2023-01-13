


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230113181729466337"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-230113181729466337"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}
  

resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh230113181729466337"
  web_pubsub_id = azurerm_web_pubsub.test.id
}


resource "azurerm_web_pubsub_hub" "import" {
  name          = azurerm_web_pubsub_hub.test.name
  web_pubsub_id = azurerm_web_pubsub.test.id

  event_handler {
    url_template       = "https://test.com/api/{hub}/{event}"
    user_event_pattern = "*"
    system_events      = ["connect", "connected"]
  }
}
