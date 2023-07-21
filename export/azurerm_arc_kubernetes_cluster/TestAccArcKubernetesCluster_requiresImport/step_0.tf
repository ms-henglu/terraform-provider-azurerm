
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011144118850"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011144118850"
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
  name                = "acctestpip-230721011144118850"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011144118850"
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
  name                            = "acctestVM-230721011144118850"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3553!"
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
  name                         = "acctest-akcc-230721011144118850"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzfPy/vli3ymlyAbfb7Mz3NhZXmg9xwvilu2VH40fwdtWoFahuCkdKDoQIr3J9gDLyrjqBmYeHj1ZDQISQh0NkNkk9n151bGWj8FTbCZmzR4/yfOz+5crW7qy/uRqXmyNf0tyRgq0+O4xbZhfJA9XthzthgUX1/5qXBi7JWU5Kt1ityzAioV6t5S30Abmcfkpi8a9i++FOQBPuHsLpurQzuT+0CZoBNV61gwGrqNWn9yRroArYMSVyY9ggusEDwo1uOfUwviGDsVEfYTG2Ppr7bp1CVHR8tgxSM4t28txId1wN7LMP5hCFw/S3CXPkSnKSxo6q87Rd1kL0ZCCH7GMuJUSFtE/U1kXRCJwAwT20P7nrTxdbVDH1w8/6F5WgqbOiZOlDAIGOG+b0DpynK8rzFSkrze7bxvpNczucs/8qQlpOfSrr1vy39BDwD16DgrpZiGQRwvoYMOnX/g42gJIa7Qc9m3HpxndXT78dsNJqAnj+DPfzpYEAEptahLO8Pnskdp1JNBQwA1rgWNpRdLb/vUVl6MIbQd9y3BgB74f53rZuxNtcS8MFZA8L3VJpJ+VCm5nmssoIQKpRtVESw3APDF2Ls9W5Pkt5ZR8vk3C0VRDQJT4xzxHOQceOq4yXOIN39kUGXH02Y0yHoTNglSPwSZZ4hY2Ype35J8+pwzAAfUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3553!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011144118850"
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
