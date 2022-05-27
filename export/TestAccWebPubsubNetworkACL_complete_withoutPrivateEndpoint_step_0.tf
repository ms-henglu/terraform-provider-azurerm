

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-webpubsub-220527024812641672"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestRG-webpubsub-220527024812641672"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}


resource "azurerm_web_pubsub_network_acl" "test" {
  web_pubsub_id  = azurerm_web_pubsub.test.id
  default_action = "Deny"
  public_network {
    allowed_request_types = ["ClientConnection", "RESTAPI"]
  }

  depends_on = [azurerm_web_pubsub.test]
}
