
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230922060849044628"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpipprefix230922060849044628"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 31
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230922060849044628"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230922060849044628"

  default_node_pool {
    name                     = "default"
    node_count               = 1
    vm_size                  = "Standard_DS2_v2"
    enable_node_public_ip    = true
    node_public_ip_prefix_id = azurerm_public_ip_prefix.test.id
  }

  identity {
    type = "SystemAssigned"
  }
}
