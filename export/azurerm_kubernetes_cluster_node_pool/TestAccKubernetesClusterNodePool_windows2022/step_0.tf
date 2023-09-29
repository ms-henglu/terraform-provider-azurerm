
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230929064631547449"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230929064631547449"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631547449"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  windows_profile {
    admin_username = "azureuser"
    admin_password = "P@55W0rd1234!h@2h1C0rP"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    dns_service_ip = "10.10.0.10"
    service_cidr   = "10.10.0.0/16"
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "test" {
  name                  = "windoz"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Windows"
  os_sku                = "Windows2022"

  tags = {
    Os = "Windows"
  }
}
