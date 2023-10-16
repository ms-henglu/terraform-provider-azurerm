
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231016033638247396"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231016033638247396"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231016033638247396"

  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "temp"
    node_count                  = 1
    os_disk_type                = "Ephemeral"
    os_disk_size_gb             = 75
    vm_size                     = "Standard_D2ads_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
