
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011203864024"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011203864024"
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
  name                = "acctestpip-230721011203864024"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011203864024"
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
  name                            = "acctestVM-230721011203864024"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8256!"
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
  name                         = "acctest-akcc-230721011203864024"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5VP0oGUsWFnQb0gLnXFzqk5+5HNr7XMy3cbgDr1J3Kupfw0njUPXxreq0Xp5xCgnpdVtrnGe74DAgQp01hLMR845MbWwxQgLgX005jfxCQX44pJCoxN8efO0GMTQv+4w0+I7IP9z11BPQ0yx93kCYo2IiBnMIsderG2muqW3+nvbVOth8tdEQsZV660/Foka24VAbryGt8NsvsGDVXPdWaFIqoJIcu+N7ItSdxw0Y0gv60aug4UdS+j2SP5K5FyY18PD0wWYZ9LN46PR8UJKEgDA2zTvjHF00vf6fHId8EfgtB2I2yn0lxFNyLfFSDxbh1AJQ1groIJxvgg8hQB2XCBGKri7as0Ta6rwS8Q6eTQfOdxH3BITNhMVz1Ncjio6qBJ/P//HKc4Fj0+4PSmTzJhQy6ngu2KkMag+Mo+VYmn5JI/0IlF60MMWN/LH04o3oG7tHjsC5knQlm8b8Z/wLKvCUHfI549aIeHv1BvFIn67bRISOMLXTO8Rc6uG9mR+b9f4u3akRZ2HSOxSV20mRiOjOZLm9ZL0pUoD3J7wpjXXCWdJ1fHTIFbTwNFrw6SHcCSz4w8cQquEbVf4WlrPlJrgad5U8RkrQS1glpW0xTzz7Q6QIi1+yj8AZ4sSdqD+1zfMKqCrNsjfr2qZfAQFBIJhSb1h7gBzpUSYFjU35C8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8256!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011203864024"
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
  name           = "acctest-kce-230721011203864024"
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
  name       = "acctest-fc-230721011203864024"
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
