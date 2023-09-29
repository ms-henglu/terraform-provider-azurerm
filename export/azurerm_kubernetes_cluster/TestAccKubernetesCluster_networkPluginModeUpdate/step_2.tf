
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230929064631536056"
  location = "westcentralus"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestRG-vnet-230929064631536056"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestRG-subnet-230929064631536056"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.10.0.0/16"]

}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230929064631536056"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631536056"
  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.test.id
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    pod_cidr            = "192.168.0.0/16"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
  }
}
