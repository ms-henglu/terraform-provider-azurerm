
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010230812221"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010230812221"
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
  name                = "acctestpip-230512010230812221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010230812221"
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
  name                            = "acctestVM-230512010230812221"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3781!"
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
  name                         = "acctest-akcc-230512010230812221"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyQ22QW4iEA2v466WJrex8H3WyBeM5hIAWIXmrCJ3zwc0+hsCwO9se5v/sgTIp2pOs/o3OC8Rw0f9Et6feBwUU2cHVUS1qxRmNI+FDIYMcgCYFGmKJyb4UM3WAaFbRPEZ6mHLO8+pb34iCODGqbxGCB3ZLz6Tu7bdtNVv72QA9ooqiB9bvXAcZ+FPN+rsG07JWBTSluc1FtM/gLhooR/V+ApAvxEy7zg7gVtErqervIaTus/8VVmpyJvbdkijZzDsG5Y0aGQOG8XAYHzCi6YxOW4xh7BAzF007uFiWaP/n3JJ4gbK7AKUTbJwAZdcd8u43mdJ9ChfwUBA5efhNzWtKXWa3i4qQgYL40K74GkbasPbILyaqLKD0hj0tEJ9FLUSQPhOdHVZ+JMVPhif49UV7aDnMbM8PuLVOO8Kj3fjoMQpDnCD1Byf+PjlccEG1FZFSzBh35HWUiWVCLSk6LVT2ltx7V+ckgWCDMDLYBXM7149jk3eW3wguym+6niwyVPMHJFBUUwVa5x6S2PEi3ZJXAl5PLro1cIo+alWUvcMqwdgHrxkRYHbhoDNCZvxWYHm/pZRBjKL0gDgsZoR9Ai5el98QVW6OOMP2Jnpr4Du+B3IyE/IlB7ZcpzmjfgDXLnV/GZycE65mrDrCneegM4DdMENO4guJ/Jl7JRZXF7qtWsCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3781!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010230812221"
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
