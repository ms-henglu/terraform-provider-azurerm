

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-webpubsub-230825025325773430"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestRG-webpubsub-230825025325773430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_S1"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230825025325773430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}
resource "azurerm_subnet" "test" {
  name                                           = "acctest-subnet-230825025325773430"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.5.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "test" {
  name                = "acctest-pe-230825025325773430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.test.id

  private_service_connection {
    name                           = "psc-sig-test"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_web_pubsub.test.id
    subresource_names              = ["webpubsub"]
  }
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctest-vnet2-230825025325773430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest-subnet2-230825025325773430"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["10.5.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "test2" {
  name                = "acctest-pe2-230825025325773430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.test2.id

  private_service_connection {
    name                           = "psc-sig-test2"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_web_pubsub.test.id
    subresource_names              = ["webpubsub"]
  }
}

resource "azurerm_web_pubsub_network_acl" "test" {
  web_pubsub_id  = azurerm_web_pubsub.test.id
  default_action = "Allow"

  public_network {
    denied_request_types = ["ClientConnection"]
  }

  private_endpoint {
    id                   = azurerm_private_endpoint.test.id
    denied_request_types = ["ClientConnection"]
  }

  private_endpoint {
    id                   = azurerm_private_endpoint.test2.id
    denied_request_types = ["ServerConnection"]
  }

  depends_on = [azurerm_web_pubsub.test]
}
