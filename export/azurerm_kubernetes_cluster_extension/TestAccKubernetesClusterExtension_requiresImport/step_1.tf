
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064631521117"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKC-230929064631521117"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631521117"

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
  name           = "acctest-kce-230929064631521117"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"
}


resource "azurerm_kubernetes_cluster_extension" "import" {
  name           = azurerm_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_kubernetes_cluster_extension.test.extension_type
}
