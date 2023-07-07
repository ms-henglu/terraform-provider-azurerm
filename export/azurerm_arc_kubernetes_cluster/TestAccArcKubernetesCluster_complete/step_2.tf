
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005954930739"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005954930739"
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
  name                = "acctestpip-230707005954930739"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005954930739"
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
  name                            = "acctestVM-230707005954930739"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4931!"
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
  name                         = "acctest-akcc-230707005954930739"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAycswin9D7EzTaAA38TJPN3oC48k8mitgZE6mkGY6F44Qn5RAxAzGQVLe9JIKiO1k4q9xMnqHtY5TVc2zxqW2yu+Auqcj2jd427Cc9x0/JadiWh3YYsUZIzaQg5qkJPmXwOA/a6HePboqDPehF2Z0mprZso6mNvJiBS5uPYsoBxjotxCdNmL+vB44nCgYNQsdh4lag0yzoyv13pAvacaausHnQIO4WXGeGbNj11Smesq01BdAC/p8sOIHuzFY8LtBdwWO59ZCyWI1MSUASn+XMWwLkvg6tWrMpwolbilvr6FL1VNAWQWYyZDTleuQK2ORADtyc8U4BzJuetcNxTQdwKNMvPLdKGiCKYV9h9KXqSiL/pkmpM/qZYzkStLqm4bF7ZkGvVvmu6V0EPfHuRRpGVhsj/emXTdpACi1m1pKLpyPP0uX+7+3YxC38U+2/msOwbI/NSoZDukHL/cPpb5eYypCPpUFm+svc90JYUJeKMDbZP4AkVtt+0WL/38JVWw8WBXfNxrm63idhE/NNKPAeCEXZmABMF20Uy/KrUVT21fWWm35K28O8KH3J8CcZ0a4gOiSFoEyVvApfAp2Im2dudMpY/+arDAD74WS9jA4jcEiKUcZEYmRrUuh5lzTCQr5kEsbA/k/EXeOuR54JdqKlLemyPzl1VtGMf3eCVB7bY0CAwEAAQ=="

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
  password = "P@$$w0rd4931!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005954930739"
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
