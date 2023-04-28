
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045220439819"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045220439819"
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
  name                = "acctestpip-230428045220439819"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045220439819"
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
  name                            = "acctestVM-230428045220439819"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8964!"
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
  name                         = "acctest-akcc-230428045220439819"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApNJqTI8DOqnswLGDpeBw2khiYFjQZlYxcQVx97hH+Ui7d/nL8VcL/UpZILs3qfwkYLVoaZ+LfhHm7GaOz9XEeWUytNdo9BpcNKKET782kbJkHnPKVB/LRWHWk1iuHZfYzbWaUHi+VSMyaVcUfSHz8aiGA/TfeXUHea3DXVEf5Fiultyd5I1RtnbRXrWxpPX9pSisW5BPTmyRZIsZ7ayp4PLcrLhAfPd6uV4AyNYP2fsU2o78ToBY2MbB2FFz1J8dvRdVyqq78h8nSqGdCXhZ2N24PvDRV+map64NXyepQpd4Y237IREJpCa9vZMk073+gikCWR+vq9H51LyG0sDTZy9fEmlRIU6aFoxGWa8O3sNIInFWTAFAO7J/O8VDP2yTBrnD9qTQezZTZ+SdB5q1GqFiZfXDGlxoYz47jImQynmLTLz7umPMoH/38cLyY9lKXgXokxsSmFpF/jbP3z8BjurpGxVxaecVKDKbFVAi8ANthHa4aN8xsTG3fgHRUNRW9SmnfUdpQMj2NANA2FY+1ucJ/gkLJQOIIn8nJGe6l3EwkcmGSGnHbmHWrkONYMYXjeqyTZASV4CUG7O8E0m7eG9c7ba4vw2AHMPy8NiqjUAOilRuj4mkJoF4FwVCdGnXVd/bgGVj/XX9M/rBjnhqRiXzTECSjhDgmetKZxB80I8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8964!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045220439819"
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
  name              = "acctest-kce-230428045220439819"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
