
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240112224211787763"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112224211787763"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112224211787763"

  default_node_pool {
    name                         = "default"
    temporary_name_for_rotation  = "temp"
    node_count                   = 1
    vm_size                      = "Standard_D2ads_v5"
    zones                        = [1,2,3]
    enable_node_public_ip        = true
    max_pods                     = 60
    only_critical_addons_enabled = true

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
