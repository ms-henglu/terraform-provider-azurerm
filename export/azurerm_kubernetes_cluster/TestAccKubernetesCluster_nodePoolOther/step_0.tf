
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221021033929423394"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks221021033929423394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks221021033929423394"

  default_node_pool {
    name               = "default"
    node_count         = 1
    vm_size            = "Standard_DS2_v2"
    fips_enabled       = true
    kubelet_disk_type  = "OS"
    message_of_the_day = "daily message"
    workload_runtime   = "OCIContainer"
  }

  identity {
    type = "SystemAssigned"
  }
}
