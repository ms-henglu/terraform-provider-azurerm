
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074247387116"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074247387116"
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
  name                = "acctestpip-230616074247387116"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074247387116"
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
  name                            = "acctestVM-230616074247387116"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8271!"
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
  name                         = "acctest-akcc-230616074247387116"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0oQRvZpOhtHGV7VuccAPD8esl5uSMeei27pCMtqlSH1CVtiCZXcaUrAr7NoIEhvP6m1Obpu2NweZFe63EhQMkqIR04Bb7o6nQLRB4u3+vkcRz1HfqMnLxb9wxjXIB7NGY4J5v4tyrxCu2wLkuyV+a7vJ89JrX8s0ZoSwJ8a2dBCoZJsfjub39S5ykDk+YKb4Y5BhDwJ2F8HNcXGjjpuuML0V/kePkRaEBSb0WFHKhS5ZhkobuTwrYetHNW1B6DWPeFFW0x7ME9iHln+UNQg4xlwBsbgZTwOeO4XMKFNxw4DmXF7ROm7zjpGyXpdJKWJ2f6pv5q1Frjz9duarv4LK03dIHoJyzOvAKDSBsZxBXoKZgCLVaWIoi8xSz+I+gYz50dETpk9m1qKRDkWJKCopYFrVDD/w/HU7ERfE8isX+h9CSmWUwyb5SpeTWQ1Oh4+sxBFSTdFSs/1WjbCT8tksFR6pL8qZlk2PM/W/MozOjMowCMcHtXjNaX4dR0SFABJvZ58vykx5KfagyH95JI5mUAAbncFN1fqEjmMkM9KCIcLjet/Ge5nrmiTdo3tE9XMNGYzOz22a7ffNjeBIz/lBNS0OR8DMlv+0KRzdH6XOJCYFBIe96jzh/IEf9s/EIMyzpA3geAQE26IPHqZwS/0iEUqp4dqRGgDSZ84S+352lV8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8271!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074247387116"
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
  name              = "acctest-kce-230616074247387116"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
