
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022900787487"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022900787487"
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
  name                = "acctestpip-230915022900787487"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022900787487"
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
  name                            = "acctestVM-230915022900787487"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2329!"
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
  name                         = "acctest-akcc-230915022900787487"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1F0lNyqhSVC6/Wso3Qeq5uwwrs3npOoYVc8lEh2WXCV1BgAk3xMw65D6lltFkTOm04NFdTQO9DATT2Z+o45qJjV7NiMrsUFkS48fRCKgIQKH4n8k6RAwuzL6osl0xuGnCkjwtv9qERqq7/UhR0pR00zl4mRqun0R/8aU62c3PaRBjITFtMbogKUx4DVknQUjvkRRyVe+xDdVrodkt8akV3kTFF1TAOLVRDJZHwtAxoi7YPSTeZgQhYHWMIuEK0VNptdVSDx9eWSysigGVhwNkLCvFvyDTVlZ4RdUoGJA5VbJZ503LrLAvyh2me9WZz6zKg4tSRzq4GRYx1cmnmZKW2CYNIQGf3+r+5qSAd828l1fzdRZlxhHURmHA6KNmPOfA9uIfMaeJbOrHqvSkTIJeYKS333hrBgngVwkqBN7sWOi7HZXwuIFOkju7QWyMjdTCdGWTkEq699MBCzVFgVj8NhMAaSIZsHzeZGeN6nqhARwjhTxi/RIInwGxFwHj2SwlgI4jqsUZ5eJ64Wx4L9bz8zOqYpgYrdyU5CSB//vI9ZCIBDSaw4ZN2ITdVeN5iYcDTrXZ+xdKsCrtI/3R6I/y8fw1K3UasIrBk6EmG+Bu+RQnEql9wxLvfxlujtyXpTAVyAVv+zUOwM5fa9CLjqN9W74tQa/IpMukNAbQTpANeMCAwEAAQ=="

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
  password = "P@$$w0rd2329!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022900787487"
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
