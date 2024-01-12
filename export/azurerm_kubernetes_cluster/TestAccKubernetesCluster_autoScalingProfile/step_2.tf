
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240112224211780852"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112224211780852"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112224211780852"
  kubernetes_version  = "1.26.6"

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4
    vm_size             = "Standard_DS2_v2"
  }

  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "least-waste"
    max_graceful_termination_sec     = 15
    max_node_provisioning_time       = "10m"
    max_unready_nodes                = 5
    max_unready_percentage           = 50
    new_pod_scale_up_delay           = "10s"
    scan_interval                    = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "15m"
    scale_down_unneeded              = "15m"
    scale_down_unready               = "15m"
    scale_down_utilization_threshold = "0.5"
    empty_bulk_delete_max            = "50"
    skip_nodes_with_local_storage    = false
    skip_nodes_with_system_pods      = false
  }

  identity {
    type = "SystemAssigned"
  }
}
