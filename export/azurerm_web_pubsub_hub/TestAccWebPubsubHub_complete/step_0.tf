

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230929065728583593"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctest-webpubsub-230929065728583593"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"

  identity {
    type = "SystemAssigned"
  }
}
  
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-230929065728583593"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_web_pubsub_hub" "test" {
  name          = "acctestwpsh230929065728583593"
  web_pubsub_id = azurerm_web_pubsub.test.id
  event_handler {
    url_template       = "https://test.com/api/{hub}/{event}"
    user_event_pattern = "*"
    system_events      = ["connect", "connected"]

    auth {
      managed_identity_id = azurerm_user_assigned_identity.test.id
    }
  }
  anonymous_connections_enabled = true

  depends_on = [
    azurerm_web_pubsub.test
  ]
}
