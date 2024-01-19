
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021524212498"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021524212498"
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
  name                = "acctestpip-240119021524212498"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021524212498"
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
  name                            = "acctestVM-240119021524212498"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3459!"
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
  name                         = "acctest-akcc-240119021524212498"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtfYi9LEjl8jbkQTTeIGJOrbQg9ZS1OLcuP6dxistlhyuKdee3RqYxILFAdJkGbgPJMqLgvSL5/cTh9qUPcn8V3IkV/GU2L4G1yAIHm/XUhQj0WTS228bCkXli9m7eXCLNnP+ZvYcgFZnRnQQaBbX7+CYLk2ZwzL4PIZms8jaCum2J219k+cl/QIst5Qj1Rz+oG1Rhl/EobXqDQ0TPV5HMvADRM1hbaiz1i/krd6oP+/NI+SfVdm/coGpe7K+a/wdIiyxpRqjXUtME0iGxGegP0lOUb7ic0RoCWi2ltu+QEersw4D87+FNYCv2Tq/nvMkB2NFcGKkX70mlGPTTyXVPC+oLBhpaJQBxHB2WRPLwOjvkMBESxI9Isw8GJUez2T6aM2IPm0IPGShplxD7ujXntZQrskTJaEDEV0lNlQ1yHHZ/g3+w6wm3yYzIkUZrJRsQev/S40NJfLHqe+EC+M9+EgUG/AP8aOGjVU+gAD6qKqvmWOGOaZAC9DHKD//Yz1aARKwh1CGKpvg3mZsPDKNAnhTFfzox2l50bVLFK0x+cSvADKpo9AfA2iwfvhsE8Ii5t7xAQe5dJnAw/asPt8oE7Uy7DYMM0pzmU9Cclj+4ofHVp1WThpswu1nNyUks3CNlMicrh0H4nNk6almVeWTeJOysQiNSdJE9yhUWKUI37ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3459!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021524212498"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
