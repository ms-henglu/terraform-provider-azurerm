
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003323082738"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003323082738"
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
  name                = "acctestpip-230707003323082738"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003323082738"
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
  name                            = "acctestVM-230707003323082738"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8977!"
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
  name                         = "acctest-akcc-230707003323082738"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvhCdgbbuRcRdgMIrlNe4g8cCxHV/AVGGGdrxVpkTQBOrK+MFYTLCY1mqYXCsIv1uwpe5d28EZOsar6wZiKfTUN36St4GCDcP6V7y8p1oUFWmzUDUGOvz5/QDlkBSYCORePCxOCKCruX8nUXk1ar3Di02qXst68VnMxuvtSrzPofxHn5H9SH64KkyVVlad2mxeV41ZiaHlIZ0mwgu7ewBUaMi/zrCKZOqyKYgqOBNf2iNXYIyCNuaR7fDkhiYyyi4mA5marmSfAIakO+c0WfLBNHGrB7n7CZkD/pz/xd9v9mfNqDLNR2Abvjyqqf8hATcvedzaPrW+skoFqX+0j9DiBFzuH80o6xe3VkKj4yT3G3KlGy19uf9xHtgM71cxMo3iOCV+Gg6B8VqUwTJk5WLaaJcGbwy5b89Tf8QB8APiKgnCJfCpNCQAjQzQq5DGWJuy82HsVcW+aPojmpnWhUrk88khN/FSSOqvCks7j2BB+FZ7evI9Q4W6DXoqHtWY6bg+30ZY5OVZQ46MdssCjB8KmtMuAau4vecqi1i4tlYDUzIipa4WkNT7iByJ5nXEvu+D6Gxpbs8M+85Cr2eQzwdizBPRrna8V/Vs0G0zSAHv0gE3K3e3EFLti53CAazGwo50G/7pr0hZqwNLLNM8zsR3XduePjRs1YFQVnpEtJnW5sCAwEAAQ=="

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
  password = "P@$$w0rd8977!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003323082738"
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
