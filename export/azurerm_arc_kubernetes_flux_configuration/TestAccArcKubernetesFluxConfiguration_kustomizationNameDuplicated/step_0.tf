
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122337530013"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122337530013"
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
  name                = "acctestpip-240315122337530013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122337530013"
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
  name                            = "acctestVM-240315122337530013"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8577!"
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
  name                         = "acctest-akcc-240315122337530013"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvrPMgMUcc4OA3HwUEWOUZ7fiRwHefkMfVf9KEWAPLbArmnWv4ZyDlGGsX7hwP60Ji0JYYcN6MKHr6A2QgQAEtpXHfweqdcbS1xwtZTOKstJnpgwhkoPzY+oRkMRVK9jwztm71S2NG6LTwAa52SvTp0vN45ew+z64opQ4XuPJisE59c29TrgQxZd1v4PCO41PjykfmmnEzOdYRIlRdEQoYeHw31++lv5QaLxBiQivW0uU4rxKye96985mIZsE7eC5rHwbKL25MZdCtmo3pUD6YyLjWKmCSvv4pLplFUMEtsDTWEChhmrRkck6W+UKqBdtpOIWbgA3LSMVpOwunEkV/Df4yq0wCP/ypwxVymh7qcVrLr8QIlJYv3/7BlkB1aBSPv0V00sMY8uBZjvEAXEHM2dnJAuUlCDkA/WsMBPt1y5zFvHBLUazIvb96HDUq4AYH708DzP+YOO860+qItpg+VZhKA16LdS75WK48EhjhysGRrRxKcKLF4IxyARyU4QORsoc1KujoM1ewj/+4Z3MRaZvc27fw3r1quyIQIyGLR8fi6nmYZEbbrYBu1DraXsjSiZJZF8l5fRNMT8nA9DQ9XpXvvRb1OEip2fT6EOypy46Fw9vYaMjaRyx0Jpsqgxdel8hnB9cDnhwdeYSjspsJ/eO1fXSJtSnvt4W8yFcbCsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8577!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122337530013"
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
  name           = "acctest-kce-240315122337530013"
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
  name       = "acctest-fc-240315122337530013"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
