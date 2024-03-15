


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240315122445316537
}
variable "random_string" {
  default = "sv1kx"
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


resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-${var.random_integer}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctni-${var.random_integer}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVM-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_chaos_studio_target" "test" {
  location           = azurerm_resource_group.test.location
  target_resource_id = azurerm_linux_virtual_machine.test.id
  target_type        = "Microsoft-VirtualMachine"
}

resource "azurerm_chaos_studio_capability" "test" {
  chaos_studio_target_id = azurerm_chaos_studio_target.test.id
  capability_type        = "Shutdown-1.0"
}

resource "azurerm_chaos_studio_capability" "test2" {
  chaos_studio_target_id = azurerm_chaos_studio_target.test.id
  capability_type        = "Redeploy-1.0"
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
    chaos_studio_target_ids = [azurerm_chaos_studio_target.test.id]
  }
  selectors {
    name                    = "Selector2"
    chaos_studio_target_ids = [azurerm_chaos_studio_target.aks.id]
  }

  steps {
    name = "acctestcse-${var.random_string}"
    branch {
      name = "acctestcse-${var.random_string}"
      actions {
        urn           = azurerm_chaos_studio_capability.test.urn
        selector_name = "Selector1"
        parameters = {
          abruptShutdown = "false"
        }
        action_type = "continuous"
        duration    = "PT10M"
      }
      actions {
        urn           = azurerm_chaos_studio_capability.test2.urn
        selector_name = "Selector1"
        action_type   = "discrete"
      }
    }
    branch {
      name = "acctestcse-aks${var.random_string}"
      actions {
        urn           = azurerm_chaos_studio_capability.network.urn
        selector_name = "Selector2"
        parameters = {
          jsonSpec = "{\"action\":\"delay\",\"mode\":\"one\",\"selector\":{\"namespaces\":[\"default\"]},\"delay\":{\"latency\":\"200ms\",\"correlation\":\"100\",\"jitter\":\"0ms\"}}}"
        }
        action_type = "discrete"
      }
    }
  }
}
