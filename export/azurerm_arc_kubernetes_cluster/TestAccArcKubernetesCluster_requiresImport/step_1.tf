
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042916780812"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042916780812"
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
  name                = "acctestpip-231013042916780812"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042916780812"
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
  name                            = "acctestVM-231013042916780812"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd154!"
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
  name                         = "acctest-akcc-231013042916780812"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAo/kmmwI+nCnBQHR3t8PXonegkVDRVNpyPowHUygn6xiO1B/yfwg9rnpj+NoyCzl0exmWOhl63uqnf2yF/AKAu9NoeeDrdOEgdx6Zg3vJc5w0kz1MaQIFiNzJTwqmk13Ws0l9ELmwoYOWofKdaIC2qK3S9Qdu8Nu9MAd27Cn5Vgf+VRkvvCndUhyAPiHFMfN3tNZFQTuGHq4Bim3mT6oAKRPLgKfIP3SVWb0Wazp71V1klZG/MrwHqJI33TaAYOlmj3hVNSEhc2NpSnSRiaxF+XSTIxdP5v4hyBoWUIJQ5Ek6lMb4vq3qAY4nkQY0T2Vg/cMxRimKT62iqBbmuewQUHMPtuv9xjhisJ3DOHboWzxPS7fSxrzIR6HWJgqmvqadAMIswW05DWYhPZCVmvHXIEBX2SdSoyRm9jjfhO0FaSsNFSVV0jbrF0rQZaeqy2hp47OlI1dMOLE3K2OfUZyJNj2r1x3UVmRikoKcq3SLUHziFPWvubWQGWWFp0T00UfjgdaHoPD4xZ9wXHyHkyLebpLPpEcrFl4QUNKZdq7S2/46EYk/TV5CLEH7ercq9BcSsEfNU9Gk/3Ckfnq8v4PRzA/CgEIglfkJfJrz+IgKxXzLzZlDLnV0J8cfU+dBiA7ZaybAH1HXlo8ji7fybM9WLGZv18CC1A9Dzy1CMUP8/KECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd154!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042916780812"
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
