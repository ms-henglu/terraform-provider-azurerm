


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-webpubsub-231020041911229129"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestRG-webpubsub-231020041911229129"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}


resource "azurerm_web_pubsub_network_acl" "test" {
  web_pubsub_id  = azurerm_web_pubsub.test.id
  default_action = "Allow"
  public_network {
    denied_request_types = ["RESTAPI"]
  }
  depends_on = [azurerm_web_pubsub.test]
}


resource "azurerm_web_pubsub_network_acl" "import" {
  web_pubsub_id  = azurerm_web_pubsub_network_acl.test.web_pubsub_id
  default_action = azurerm_web_pubsub_network_acl.test.default_action
  public_network {
    denied_request_types = azurerm_web_pubsub_network_acl.test.public_network[0].denied_request_types
  }
  depends_on = [azurerm_web_pubsub.test]
}
