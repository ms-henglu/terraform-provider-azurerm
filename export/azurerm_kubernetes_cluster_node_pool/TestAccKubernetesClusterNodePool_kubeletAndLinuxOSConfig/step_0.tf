
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230825024306189683"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230825024306189683"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230825024306189683"

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
    cpu_manager_policy        = "static"
    cpu_cfs_quota_enabled     = true
    cpu_cfs_quota_period      = "10ms"
    image_gc_high_threshold   = 90
    image_gc_low_threshold    = 70
    topology_manager_policy   = "best-effort"
    allowed_unsafe_sysctls    = ["kernel.msg*", "net.core.somaxconn"]
    container_log_max_size_mb = 100
    container_log_max_line    = 100000
    pod_max_pid               = 12345
  }

  linux_os_config {
    transparent_huge_page_enabled = "always"
    transparent_huge_page_defrag  = "always"
    swap_file_size_mb             = 300

    sysctl_config {
      fs_aio_max_nr                      = 65536
      fs_file_max                        = 100000
      fs_inotify_max_user_watches        = 1000000
      fs_nr_open                         = 1048576
      kernel_threads_max                 = 200000
      net_core_netdev_max_backlog        = 1800
      net_core_optmem_max                = 30000
      net_core_rmem_max                  = 300000
      net_core_rmem_default              = 300000
      net_core_somaxconn                 = 5000
      net_core_wmem_default              = 300000
      net_core_wmem_max                  = 300000
      net_ipv4_ip_local_port_range_min   = 32768
      net_ipv4_ip_local_port_range_max   = 60000
      net_ipv4_neigh_default_gc_thresh1  = 128
      net_ipv4_neigh_default_gc_thresh2  = 512
      net_ipv4_neigh_default_gc_thresh3  = 1024
      net_ipv4_tcp_fin_timeout           = 60
      net_ipv4_tcp_keepalive_probes      = 9
      net_ipv4_tcp_keepalive_time        = 6000
      net_ipv4_tcp_max_syn_backlog       = 2048
      net_ipv4_tcp_max_tw_buckets        = 100000
      net_ipv4_tcp_tw_reuse              = true
      net_ipv4_tcp_keepalive_intvl       = 70
      net_netfilter_nf_conntrack_buckets = 65536
      net_netfilter_nf_conntrack_max     = 200000
      vm_max_map_count                   = 65536
      vm_swappiness                      = 45
      vm_vfs_cache_pressure              = 80
    }
  }
}
