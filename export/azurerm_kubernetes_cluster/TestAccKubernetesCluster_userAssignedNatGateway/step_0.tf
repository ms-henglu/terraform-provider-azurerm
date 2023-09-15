
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140752667"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230915023140752667"
  address_space       = ["172.16.0.0/20"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctest-230915023140752667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-PIP-230915023140752667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "test" {
  nat_gateway_id       = azurerm_nat_gateway.test.id
  public_ip_address_id = azurerm_public_ip.test.id
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["172.16.0.0/22"]
}

resource "azurerm_subnet_nat_gateway_association" "test" {
  subnet_id      = azurerm_subnet.test.id
  nat_gateway_id = azurerm_nat_gateway.test.id
}

resource "azurerm_kubernetes_cluster" "test" {
  depends_on          = [azurerm_nat_gateway_public_ip_association.test]
  name                = "acctestaks230915023140752667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140752667"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    max_pods       = 60
    vnet_subnet_id = azurerm_subnet.test.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    pod_cidr          = "10.244.0.0/16"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
    outbound_type     = "userAssignedNATGateway"
  }
}
