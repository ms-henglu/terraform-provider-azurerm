
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053601718007"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053601718007"
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
  name                = "acctestpip-230922053601718007"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053601718007"
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
  name                            = "acctestVM-230922053601718007"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9236!"
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
  name                         = "acctest-akcc-230922053601718007"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAkZ9KPh9Qh39QVQNDG1UeU/aJAvRyFPspZh02ngDuW7MHHoT+cWwzz/5xWruIpdXc3dZ01ldFKAD1ZoqmK2nSk1EPB9O8inRb3o03O8XxFyMHTjv03tIA1UqjIw3yEzLrNYLGdxiG2BRoWDfAVeogItmjSBg2QXuYcalBlf/1QkjXxy2/3qWZfIhzqtOBFry4fOToKh8nFOx7aYXmX9cKZR6Mxn6LGHvfLcbEBzN5wGfzWFvsYsVJKOrNyyleAbwvHcOKQzy+FIQy5I1xRLS74zOw0XUkV9EwHeog+iKa3vGe4Fk9TRjbuBK1Jp/1I8qUZ/URDbpcfE1Ds6jOawr6hilNl/zgDE21ExTvloR508QAvh4kBTdSTlna5mOE6+2pE4gzOsQ1DxGTbSJrgIiuJfEiM+o3+mlapLk5t6N/DBB3OEpqQoz0BxKYOdmja/9+d+48cSwKScLefLZD/P//IhURzu/YqyEW4xwUH9L+rvzByxKgcL13jSAjAG6+0rThV2J3uYZgNjdBBBg2Asx1HQRsPgEWE6NfTAOCDIfpSellBpbj9oPWGiEUoZ72Ki3havxWi/+EjwIA8xXGOTQIM95PaEsXYan5rIpbwEc0Z0gKdUqWcIDwbJOe09WyxKAeeekXbRtFoEJCftrtxEwNxIjMj5s64kcNiCyPhDawz9kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9236!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053601718007"
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
  name              = "acctest-kce-230922053601718007"
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
