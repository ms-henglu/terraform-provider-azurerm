
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223931797980"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223931797980"
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
  name                = "acctestpip-240112223931797980"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223931797980"
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
  name                            = "acctestVM-240112223931797980"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1909!"
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
  name                         = "acctest-akcc-240112223931797980"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAw7isgtEhjxVjTNyTpyzdArRveCjjj3iopYupHsUVRFtQbS65XgwN5wokkYjNkvxDtRiHNz95DncUBFuf93AeKz5l7GJzJgwZHQvASRb53Z+w1PJrzwwxt/haWxR+csITsvKSQeI2hvf0OGSGvRR3D1bqiYfcPOc8YhejCt5lESwOfmY44sio5y8J0+fGnAEn8YNN/ER57X7BJ216zsFqNU4K+/h9K3AVuwYeYk7Pm/T3bQRFnmL6gt+TAXAGIgw8Sb88SxPGeqS1c3YN97bdM6s29BS/2Btr0ZzrWdWOf40u3MFv7WBZVgcXn3GxuFQ8pH7iWW/b5oFAGTKnpjTJQrr5hSQLPeCsA2hf0QpA3PB4fFvpAo6nhWkfvwuUl1XUQMnGuF6uekrbwYV/jScbyLSlzykkfP3IZD91/T/N82kKGYRG82eS74Aric6gMt+NVfSOd+nePFv+YQ9t6LLcNvV4bl2gvTXCYtkMcaA8zUXBhqjC4uFGgBanJTIZjTY6q2lM4v87Pub8gnbnyA26fY2yvBB+sWKvnRj+J28VMjTYDH+rZwrl1755owLWvh6DT6y6QQ4ufVpMUcoxdOTrlrOkC0DxmUdKpKFhHZMFFNWIWbSLA4AeqnIrvKEdTq3MWudOiSa5ldQfA6LE8AI/vBBuVS37LbWJAoXc5B3yn4MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1909!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223931797980"
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
