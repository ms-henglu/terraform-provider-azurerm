
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090832256030"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090832256030"
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
  name                = "acctestpip-230609090832256030"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090832256030"
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
  name                            = "acctestVM-230609090832256030"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3928!"
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
  name                         = "acctest-akcc-230609090832256030"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA57/YJv6o671mUOS5ZViWQbsUm6vGksKfM54gH4vv5XApsxNQKPZ7SRdjghY+o47nLJc5eGmS1py8cEKICB/wNdZQxXFZ5DQMGwudSxCEiO+DKxBF6hdevQaIAUFHnszxkxRXpNngI32VME2YERsALl70dGIDfwlrXN0WFpuYLdliB4ex8gUcyPny8ERoGcbrdP6sO2Hg1su+ydKc4SCfWaEXYqM0+VZtl9jWUEUycysof5PkhNuhgCrVV66MLTLL5jGVdNx6X3lVM4pKoYCq25tnkiUJWdF6bfc5tE75882cysogRDEgACMYRTpgww7S+t4Rt4R1HuUjU4yJyHtt1T2/kPWxC+mn1JceptY56dC03uvZ2LbFBY06fIGazJqMABXHxeVh1/ntCW/BC37rQwolExZOlxcAgqK67d6ncNK/BDJ9k260kuuRzSyKZDnNjFaRVaHJoH9IYSxKarxXU3RbnZw2JZGI2Xio70oBOQEyjJpFaCPX/5UozNJOHMFRHv+IYB3DobIoB1LuNBcqicsIPSlG5MX1V38HRr6p+ZwNXnGuSa19leVfhpClyXCf+9zNA7VnZaETCnbhR5tazdas1O/uT+V5QUfFWfUAq9hzGP5vF+HOkxUVWwEpNEKdZlRPTX300HrLnbwE+VOtbDjSF3/ruCBzRE9EQEVYl2ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3928!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090832256030"
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
