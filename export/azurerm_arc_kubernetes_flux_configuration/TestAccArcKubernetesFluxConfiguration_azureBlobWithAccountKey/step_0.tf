
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014516934955"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014516934955"
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

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230721014516934955"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014516934955"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230721014516934955"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2516!"
  provision_vm_agent              = false
  allow_extension_operations      = false
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230721014516934955"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAp8KT2wUMC4l/vjpq5MFXZHaaXUHqSfsawWJpxJHfaVmPRXoc79ZYIPSp44kN8WtBnnUc1UFiQfLRqC94unEr4+WVIewg2dwPkyvawcaT+UyhCFn1dToBYukIGNPiFjcMTm+LFLvvDCyU34D1qzzKBt+IfCcsrcIUBSEYH6raLqcEi8HuYyU4dL+35eFIknrH8HFqUZW7osp/r5zXkxCbetkFVgdI/HfpT6w263zh+3nVW1HtPMGJFKYe1DjjtXFyqW8BEriXor3xWsRqtXTBpMx4Pe9gy3mg7LEltJZsKzPKU3TZKrWzDYyUcQGSOo1iq4/tbUc+rdqtWjQ6QQBH1aSrAySQmDyDaatQlChaT2bMBV/SvjjbbZBOJqe+8K9eZB+U6pIJawT44owXGMcgDwuaozUaXgstfJ7Y7V1dFsMFboE5EOSXWDSqKoInX7pHFoGysiPXZU5SMrxh1X6lQiGD8v/1cVLmvvwkeXQBzjQJW9yjZ2kXhXh9pjthHpRY4IFge6s+FJXtH0KkdDyJQzensQu/j+E6i++APZWdO4P4tItvYGCzpDwda8dp7s85zCd6rLinzjrmF2ePPzaiFvOhPwHxivB6pu3VStj3ZxMYR2SVaEfE5B+AI9TWSrmnxn+5SX14OLKc9KKXkgyZgiglsYkHkmwHiM7izXx+OPsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2516!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014516934955"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-230721014516934955"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230721014516934955"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721014516934955"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230721014516934955"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
