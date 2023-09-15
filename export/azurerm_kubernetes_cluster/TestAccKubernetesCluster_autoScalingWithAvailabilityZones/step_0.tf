
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140800814"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140800814"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140800814"
  kubernetes_version  = "1.25.11"

  default_node_pool {
    name                = "pool1"
    min_count           = 1
    max_count           = 2
    enable_auto_scaling = true
    vm_size             = "Standard_DS2_v2"
    zones               = ["1", "2"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
