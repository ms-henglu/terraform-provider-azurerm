
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140767699"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140767699"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140767699"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1

  kubelet_config {
    cpu_manager_policy    = "static"
    cpu_cfs_quota_enabled = true
    cpu_cfs_quota_period  = "10ms"
  }

  linux_os_config {
    transparent_huge_page_enabled = "always"

    sysctl_config {
      fs_aio_max_nr               = 65536
      fs_file_max                 = 100000
      fs_inotify_max_user_watches = 1000000
    }
  }
}
