

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-signalr-240112035201535930"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctest-signalr-240112035201535930"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}
  

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240112035201535930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-240112035201535930"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "test" {
  name                = "acctest-pe-240112035201535930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.test.id

  private_service_connection {
    name                           = "psc-sig-test"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_signalr_service.test.id
    subresource_names              = ["signalr"]
  }
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctest-vnet2-240112035201535930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest-subnet2-240112035201535930"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["10.5.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "test2" {
  name                = "acctest-pe2-240112035201535930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.test2.id

  private_service_connection {
    name                           = "psc-sig-test2"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_signalr_service.test.id
    subresource_names              = ["signalr"]
  }
}

resource "azurerm_signalr_service_network_acl" "test" {
  signalr_service_id = azurerm_signalr_service.test.id
  default_action     = "Allow"

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
}
