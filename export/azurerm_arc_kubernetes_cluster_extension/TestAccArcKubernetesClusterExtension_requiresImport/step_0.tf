

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040520280783"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040520280783"
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
  name                = "acctestpip-231020040520280783"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040520280783"
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
  name                            = "acctestVM-231020040520280783"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7911!"
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
  name                         = "acctest-akcc-231020040520280783"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3VkktweieYpWBuDuXabZC9fdeoxqdGqQdkUkKBQzqeGVIvu4NJQlqX2pT0LRzvRGf3NUmAoaM6sqJfONbsqLWZnoiyuP7zVLs27su4BbqOjTADpzZCG9T7W0GT+z8bb4MTGsKX8YZ3L0TMSRXwKHePKbfi+Dfpi6M4omxkuZkxW6+ywK9E5WEzT+H1sjM8t81EkfWVAjiwk5aU+UTaj2IADNKlRs5uXxRspg9WJUNVOHrj10DRUjRsYJwH1RiQdJDL7WHE0ydt8JIGJY0fN6ugGJkDsIevAprxXgfxQBuD/URvtObCmX6lSTy4CCrct5Qjss8INVWVCciyUPS1wiJiq+kgk4cfkl7CuCRivwZuWg9gCeM1fB7tHhwwvz6j7CxlK8R7LqGZcm2hl4WgB6fXFXjmozA5dWAkbZI6+SBmX4GiuPhcwiUlxyIaGw12Fr/VrnCIbWDgJOV2wS4bRioVgA+670RHQuk6g3L9sR3DE5Kn8VOFeLsGDAYayc8kb0PKPs5lMIkragKAFRUk4XOqoPD3FN9GFDkxrbsbj6iDKan7w5rj0rYDazsrdTGKeNexIhDSOtjdc0ZdFH7hYLNw8zxj5rcpzfaI3GOmYogNQZ48HiYfVJGeSkpYqnrJbd+1TXUTy8BBxxVjqlDJckEeWRDnqof6d/RrSyF7NRPRsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7911!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040520280783"
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
  name           = "acctest-kce-231020040520280783"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
