
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033638186613"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKC-231016033638186613"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231016033638186613"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231016033638186613"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"
}
