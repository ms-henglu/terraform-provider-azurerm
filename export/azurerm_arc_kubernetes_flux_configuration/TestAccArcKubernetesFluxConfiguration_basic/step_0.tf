
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071233085196"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071233085196"
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
  name                = "acctestpip-231218071233085196"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071233085196"
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
  name                            = "acctestVM-231218071233085196"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6133!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-231218071233085196"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsXQiHghA8v9QtZngrhAXzdyn16rEUvrbF8VvO/ghweRDMgrb899BPOksxaYfQbT8qHL24T2Tyf8NCDCaHiuY/4JRS5keyt0OrHnIXj+I6kEpEz14OCcV8K7lUIET9IdzJUs5hZMYl5E9yNVh5EXs+xQOmFBduJfX5a6cR9qU0URMPUno98iAca7f7fGIGMAGKSxofyTIqvPi5Rv2y9gidiRDCyFr8tJzssNGFaalstzULRb7hIhvsUvYZiUoDJy6/CUnFvTEUDcMzlVVvXRyb1ED4fsLJEriFju5Ko3hkVPt26m+MXTiMuLAkHW+RwFaMfzrfEAzF/RpyFM3zgZ5N2uS6tOLiOZGgZk4oWgj8TmmQ7f9kcol3pl0dVSHnXUeGR2J2gLpT+SAH1a/jAfrq+VGPHcr4u6F2dZj0Z9xjPv6Sr26w3b+e4IzkBwVYjd5W2fQDBlfNFGwM/z3rsDPatQmexugaDmLpWt/OqbfVvxXYHTPzFTrfeJGGS4yhVNajLrxknzMo2hX2acO2Pn7krLXD5v53RJyL0w0ASnNkBd0iu2/Kp68k9ODjQ2R4a8E8tH9L/khzvHjq9OmeKL9s4nRwxdXDew3XvHFJS7DHMPQffQtiVXpSNTr2dKouM7IDfBuFrdajLhwWHJZ0B3i/y3p7Suy45jg8veEEGv4KVsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6133!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071233085196"
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
  name           = "acctest-kce-231218071233085196"
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
  name       = "acctest-fc-231218071233085196"
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
