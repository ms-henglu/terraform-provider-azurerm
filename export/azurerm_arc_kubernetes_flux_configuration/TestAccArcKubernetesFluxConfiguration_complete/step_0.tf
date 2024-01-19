
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024508316246"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024508316246"
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
  name                = "acctestpip-240119024508316246"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024508316246"
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
  name                            = "acctestVM-240119024508316246"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7995!"
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
  name                         = "acctest-akcc-240119024508316246"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArxpOpr7Uag40DNvCErfKjN78Zx6mIH7ZupJY4oARElkvat4+2eCnZ8VI5TA5Wsfu5q39SRaDWMzt7fo83QtIhfO/gKZacBWRBP5K3PHZ38OteayrmPdQ2oLx3kOIdQQAzLahYFtiz17YIrmt+Ul41pB0iY0ZVRro5guI+tqHTDZqpTfg2RuwowVM4XeP7hoEj6b7csE7zSH7yfxyh9XqnTpMHrM/TFsbY+j0KAqaYUxMPfYhzPu8JuZscTe+4zwXKpNRpPcZSwC7kAvYyQNI4BV1DEy2Eyhf4dlU9nx4QDcn6QNWyHno/e0ViBhV6yd1K6MBnhEsRfKWbdlb6IZEkp6Z67jx4psbdl1x1qRozs7ZU9Rr/Ypncp1ggCpJ3dcQAayFkSUmzQQP2wAcuK3kZNZc/l1PVagsm8jy7ZR+kqFV6POU2Zlbk+oTnJWUzi9MelBE7kjMQ6QIdUiHSitBlGAm9gj/XeJZYp44bi9naSjyiWs4I2zXIH+w8n8htg8ZKpdQx9cyqQSAV6O5+eMFgDBt3Ek4hAvSe0Ygg7hPn70DvhSYBqMiIeVglN3lLNaFzChmU4uFndbmNzUMalDAiOscL/dCPDR4cYxj1KfkqzFqEjRgdFi8eVRqMmxUa87wdbLi/SVuJvvjJE+nhsdl5gvpPco2WoyPh48m6CSh2YECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7995!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024508316246"
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
  name           = "acctest-kce-240119024508316246"
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
  name       = "acctest-fc-240119024508316246"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
