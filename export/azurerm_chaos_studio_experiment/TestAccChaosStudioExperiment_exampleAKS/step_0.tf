

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240311031511256246
}
variable "random_string" {
  default = "9ttwp"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  name = "acctests${var.random_string}"
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

resource "azurerm_chaos_studio_target" "aks" {
  location           = azurerm_resource_group.test.location
  target_resource_id = azurerm_kubernetes_cluster.test.id
  target_type        = "Microsoft-AzureKubernetesServiceChaosMesh"
}

resource "azurerm_chaos_studio_capability" "network" {
  chaos_studio_target_id = azurerm_chaos_studio_target.aks.id
  capability_type        = "NetworkChaos-2.0"
}

resource "azurerm_chaos_studio_capability" "pod" {
  chaos_studio_target_id = azurerm_chaos_studio_target.aks.id
  capability_type        = "PodChaos-2.1"
}


provider "azurerm" {
  features {}
}

resource "azurerm_chaos_studio_experiment" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestcse-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  selectors {
    name                    = "Selector1"
    chaos_studio_target_ids = [azurerm_chaos_studio_target.aks.id]
  }

  steps {
    name = "acctestcse-${var.random_string}"
    branch {
      name = "acctestcse-${var.random_string}"
      actions {
        urn           = azurerm_chaos_studio_capability.network.urn
        selector_name = "Selector1"
        parameters = {
          jsonSpec = "{\"action\":\"delay\",\"mode\":\"one\",\"selector\":{\"namespaces\":[\"default\"]},\"delay\":{\"latency\":\"200ms\",\"correlation\":\"100\",\"jitter\":\"0ms\"}}}"
        }
        action_type = "discrete"
      }
      actions {
        duration    = "PT10M"
        action_type = "delay"
      }
    }
  }
}
