
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-221221204115072700"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks221221204115072700"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks221221204115072700"

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
