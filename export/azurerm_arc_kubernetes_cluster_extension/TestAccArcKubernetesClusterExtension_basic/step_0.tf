

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053553782280"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053553782280"
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
  name                = "acctestpip-230922053553782280"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053553782280"
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
  name                            = "acctestVM-230922053553782280"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd36!"
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
  name                         = "acctest-akcc-230922053553782280"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzd4nEx/SsEXsNHi+C2WW+b8szmx5RQ9vMvdjTJNd+0rmO8R7vUp/D5P7oeXoRdCvfs0lhXL/wD+pZGmbj6q6vc+ICWzIBjUw45Tl8cRjegjqbQsU/wpfi4J8ie+Ms7+LcI6/Az8BrC/0/2FDREgdTJtqRc6RI9JULM7/TunLB+kUgTFay2veiqedqY6HKsgr0wNG7nwLhx3bszUf5GXhBSl47MmyMhrrK90YZ+jKeVU3mxAROPSodaLXj1H4Fz0AIVJfoYXrEIX/CMTAPVbhgt8XB1dpytF5RkL4Mnosmb5qGNdBtP1F31vsnf+kdLRhgvMqCpSSmvW8PQlA2sT+7FaYSXrcIdTGo1DCq6lE377hDRrxlutgNgojRqQTlC0w0UuaIBvahCBD+WB4VCPUNVfkD/gFPbPsW+vH0GqfOgPGXsphlD6pjqr6yuxdbcUgDhOn3/kQZNQXEaZ+1oEo01g+35S5/PR66F+EenWkO9fpArN7ImsFIiCjl+jV6soqoPrZkJvoUB4ml/+P3g9KLbLma7WzT7edlalS02+lTspmIInRA/htEXKQPXhT835wZ7adNKXtdFA9B2X1zrqSnG1+0Cj7164lsk4KExE1+rxbpwL/Uui0ppeuAWT3YJeD5G3xMr2TqtyDzfdWEmwvWP2jXMwKPlGag7PX37TqZ8sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd36!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053553782280"
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
  name           = "acctest-kce-230922053553782280"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
