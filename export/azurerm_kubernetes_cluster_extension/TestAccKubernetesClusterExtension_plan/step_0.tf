
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033638183742"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestAKC-231016033638183742"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks231016033638183742"

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
  name           = "acctest-kce-231016033638183742"
  cluster_id     = azurerm_kubernetes_cluster.test.id
  extension_type = "cognosys.nodejs-on-alpine"

  configuration_settings = {
    "title" = "Title",
  }

  plan {
    name      = "nodejs-18-alpine-container"
    product   = "nodejs18-alpine-container"
    publisher = "cognosys"
  }
}
