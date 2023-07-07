
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003336975402"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003336975402"
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
  name                = "acctestpip-230707003336975402"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003336975402"
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
  name                            = "acctestVM-230707003336975402"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd549!"
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
  name                         = "acctest-akcc-230707003336975402"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwmQAZzQyBG0iPj0eUmFYzo0LEyCOW5svbaaw/ceSXCWhXL22EvZiH5BVjLsJJmhDyGJSgSpOaCC2c+HgFhof+O5CzLQPeMeRkM1YOWAbiYKUtcpFp57T+lyhkISvRYzX1tPqleHNMGuPZ1EIsDBm/mGhDNshkJbRSHXj8wFhX+4NHToDwPIZLpEgGwBrcKC9POkf07Y5XJcZ4q6NgOM9xRiq9gW4r6B1+l6yxS7NnwagDr977MuSfK+97KCen7IaZeIfAg19i644ozu899XHB4xrBTtlTHDTRIIWHD1Eiza2+jvdvRi/1yqQT27gLZUci+tHuG4IDgdwLJX7UoXE+qP9Lxyg6TBcf++parfU4DVjgfpmd3sXl52Fc5yY5pKpUZYzmxH1wNENpSpm75Ice9q9PEwv8zvE1uzKRMVKiuHX+WhyREBL9ZaOKmoClxprrmt5XiqF2+4bAx8YN7BK1wn3j34ckAIBeQ13qjQ2WD6kPP3yRD1cuhuUNmaE/V2Jj0a3hFw5djGPOsgkPzuvh5ov5E4lIPHoEMKE7W5uvseYY0fiWhzv180TM+bx91+EI+obT/V9OEYfEn2w4boRqMQFh/guvUPw+IoKr3d27Bb0kffx99i3eNf64gTQTpCnPM07wy7tWGLEjxwWHeQJX/1hte7gnmKa1Wai6L72MSkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd549!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003336975402"
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
  name           = "acctest-kce-230707003336975402"
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
  name       = "acctest-fc-230707003336975402"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
