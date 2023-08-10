
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142944616217"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142944616217"
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
  name                = "acctestpip-230810142944616217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142944616217"
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
  name                            = "acctestVM-230810142944616217"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8431!"
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
  name                         = "acctest-akcc-230810142944616217"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtrTH282knLYc5DxfU2gpiqdDKJM8cf7zDNEPSK6IFBevzHhXcqNZKT1ustyc8BZviDDHA52WKZ8JnomO8Fdc4pjCyXC0/JP0VKSLl8ZisG+wiZ8BVR2OyekX2ghxFAhkCH3TYgzXbh6C9906wdqH+noZTl2d2z3RTXZ6l4yEqjpZD6+Z5QrPAUfQAKY53jIEAtqzdLEqhuvDxI0/7X7CgVb0AEFqJZwll7zfqiHmb4PayUBW/RwWAbQOsf4AGBnOg2iarofxpWjRLh/eYg7GbjCNy+sq3ml1zIL8inQJGUFfMlMOU3SgygAfeE0PFFVNu3j3oDTc7hmdJu2jGFaUjOoFr1/5zB4LmxKzlY0JHlYWfG5RJfjeOEosvSZYlvu2P09YUbw2XmdkSARsXKkCwgxqPcdDnQ6Qt3jlojoBXSzsyewyopLk6pyQWziTIdpodlL78Pl9bHbUgljYtPpFsrVgKtir4/EyQ3jfpyLSCgcgVRvQ5GFh8B3oQQfN9nydo8HTy162MRgWNYNQlAGZknpSsJIZ4sWz0BRUUD7XbL2mRT0EM4HSvia400437pwTHUdiS0fdK6PfabyZqCdZj/I78oDE7d9yWtw7UhDTmTzdVFJ3MDUWlFoYiB+irnI4Rt1MFLq2J4HtC2J0yf7aOC5vWeLydCGsvBreHfW9qv0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8431!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142944616217"
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
  name           = "acctest-kce-230810142944616217"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230810142944616217"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
