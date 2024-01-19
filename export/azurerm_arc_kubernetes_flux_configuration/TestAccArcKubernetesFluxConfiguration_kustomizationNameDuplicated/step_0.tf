
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021549261936"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021549261936"
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
  name                = "acctestpip-240119021549261936"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021549261936"
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
  name                            = "acctestVM-240119021549261936"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2172!"
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
  name                         = "acctest-akcc-240119021549261936"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv1e6679bjZNAZxfc/PPLc+PBvNr9mWNKoWll0cK5ha+TEW+8yDAo42gVn1OAUhCF9lkCU6n5/cb5QUhhtZdxr7bRSDOz1i13aYpGGAA/Ig0jrcjJo4EgsDvf8SOOW1tKRoxxtNAyF/xcgUvSUEeCTXUCeZSRgBv7NW21W6a81vxqORf1+O5AA6mjdUZRqF56DyUulysgiJV5OLlRmbqGsmWtvH5KmFocbNMXA6yMgaosGGPEUPYuNlUh/304RJ/bH1g1B7tC2DOKyD0Ox8w/1kNi0RTdNwAuvNrEDtSQzK65V31OQJ5Q3NTfszjxCZYyIyKrPfMTR4hRnwpxzag1EDt4JvqdkzvaSFadZnvgy+sRe9lABlO57jCXrmRr4F2aAIaPfbBGwpXGHVsCtFWpXBnM8pCXZ/M0KG3i05ePbipXX6ddwgkmJRnM8Gqr6kP+yUJEtQv0IbwOxeqYXQMpfL8QxoyfznWb1Z5RIq//HYJHHz4QA5fdszDZSvABwoY28M1UVH/eePrzjLXYfCWHX58NT6FqQnsrOhysg81b7i+XCipMqBpA9wA7N5nudwQG/+fYjEtGo40yW+SeQzNCtZ9smeyaRlDlB91eOXcggSn2vWPcWhNKVNQNf0Vp2+51XF4hZjHdbYSyVFWmQxvnh9Uor5HRbYymlvolEKsUem8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2172!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021549261936"
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
  name           = "acctest-kce-240119021549261936"
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
  name       = "acctest-fc-240119021549261936"
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
