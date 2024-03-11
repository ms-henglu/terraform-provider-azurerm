


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240311031511254736
}
variable "random_string" {
  default = "tbes4"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks${var.random_string}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks${var.random_string}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_chaos_studio_target" "test" {
  location           = azurerm_resource_group.test.location
  target_resource_id = azurerm_kubernetes_cluster.test.id
  target_type        = "Microsoft-AzureKubernetesServiceChaosMesh"
}



provider "azurerm" {
  features {}
}

resource "azurerm_chaos_studio_capability" "test" {
  chaos_studio_target_id = azurerm_chaos_studio_target.test.id
  capability_type        = "NetworkChaos-2.0"
}


resource "azurerm_chaos_studio_capability" "import" {
  location           = azurerm_chaos_studio_capability.test.location
  target_resource_id = azurerm_chaos_studio_capability.test.target_resource_id
  target_type        = azurerm_chaos_studio_capability.test.target_type
}
