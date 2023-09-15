
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140790902"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140790902"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140790902"

  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "temp"
    node_count                  = 1
    os_sku                      = "Mariner"
    vm_size                     = "Standard_D2ads_v5"

    kubelet_config {
      pod_max_pid = 12346
    }

    linux_os_config {
      sysctl_config {
        vm_swappiness = 40
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
