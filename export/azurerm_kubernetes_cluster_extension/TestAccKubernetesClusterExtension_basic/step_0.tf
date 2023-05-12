
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010437923103"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKC-230512010437923103"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230512010437923103"

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
  name           = "acctest-kce-230512010437923103"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"
}
