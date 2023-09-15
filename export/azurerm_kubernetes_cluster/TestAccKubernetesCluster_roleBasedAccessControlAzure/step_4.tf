
variable "tenant_id" {
  default = "ARM_TENANT_ID"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140746921"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140746921"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_prefix          = "acctestaks230915023140746921"

  linux_profile {
    admin_username = "acctestuser230915023140746921"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqaZoyiz1qbdOQ8xEf6uEu1cCwYowo5FHtsBhqLoDnnp7KUTEBN+L2NxRIfQ781rxV6Iq5jSav6b2Q8z5KiseOlvKA/RF2wqU0UPYqQviQhLmW6THTpmrv/YkUCuzxDpsH7DUDhZcwySLKVVe0Qm3+5N2Ta6UYH3lsDf9R9wTP2K/+vAnflKebuypNlmocIvakFWoZda18FOmsOoIVXQ8HWFNCuw9ZCunMSN62QGamCe3dL5cXlkgHYv7ekJE15IA9aOJcM7e90oeTqo+7HTcWfdu0qQqPWY5ujyMw/llas8tsXY85LFqRnr3gJ02bAscjc477+X+j/gkpFoN1QEmt terraform@demo.tld"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = var.tenant_id
    managed            = true
    azure_rbac_enabled = true
  }
}

resource "azurerm_role_assignment" "test_role1" {
  scope                = azurerm_kubernetes_cluster.test.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azurerm_kubernetes_cluster.test.identity.0.principal_id
}

resource "azurerm_role_assignment" "test_role2" {
  scope                = "${azurerm_kubernetes_cluster.test.id}/namespaces/default"
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = azurerm_kubernetes_cluster.test.identity.0.principal_id
}

resource "azurerm_role_assignment" "test_role3" {
  scope                = "${azurerm_kubernetes_cluster.test.id}"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azurerm_kubernetes_cluster.test.identity.0.principal_id
}

resource "azurerm_role_assignment" "test_role4" {
  scope                = "${azurerm_kubernetes_cluster.test.id}"
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_kubernetes_cluster.test.identity.0.principal_id
}
