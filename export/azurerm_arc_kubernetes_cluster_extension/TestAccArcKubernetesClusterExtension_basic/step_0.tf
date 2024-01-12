

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223918453932"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223918453932"
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
  name                = "acctestpip-240112223918453932"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223918453932"
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
  name                            = "acctestVM-240112223918453932"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8169!"
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
  name                         = "acctest-akcc-240112223918453932"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxmNCn3GjUu8Wzdj6bFjpJlfmOf/WL1exlbvRhw8IR/uGy+eTrUBLslrDrzSzspTV15Ybv3hh1TbXbfX5Z6eGz0TmgdmGVfRbKkX0HSx89fx5HjQ3IiUzQiLUl6Vhu7HwKl6m0C5cJEM2iAoLf26FdR/mDp6yUCrbxUQw5Bi6h8cpXt7lzc6e2atgQspIugZVigEGuTtXBpPWFOjzPwTGvVMfLxgAKfZozsthp6NlAXgali5xOxemokbkAa6wNqiJUx3Q0dITvTrO56DsPRmt1qKj+6lGJQIxyVsaS3fOSaXCa3+nGYfV8Y5soXnWnPQj8HDp63GoqLArUnKFLe/1/phcj7apgpgs6QtCjAqZxSWa0DzxCU2BeHq8ghhBphbmODA5qzGrSCaMmESriNm1yb28zhtO/I1m5Fay+3oyusPTQMkBOu/bXq/1pRTubJrIn4eMsXd0Xu4FDjTis/8NLofy7J1g8cj9XZFbiTLrdqgTR8/DYKKDNeN3xwXEGwWon6Aw7W65OpAZsdNZKZe09LVHy90xqepzTJBGfhtHhzYJymx1YmbMcSbFr67arLen/X8vG49MkuUR9/9V9eHVCzz83BZMy6MePWpf3y4bjLUjN+hYOIlidHTTwOWyu2f40+wDMn5sMvrm+4+HD9Rz30LXmtu5b4Xy1cyUJuYZxBECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8169!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223918453932"
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
  name           = "acctest-kce-240112223918453932"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
