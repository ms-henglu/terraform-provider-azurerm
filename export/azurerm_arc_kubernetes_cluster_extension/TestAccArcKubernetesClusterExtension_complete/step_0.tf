
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014447409587"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014447409587"
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
  name                = "acctestpip-230721014447409587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014447409587"
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
  name                            = "acctestVM-230721014447409587"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6496!"
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
  name                         = "acctest-akcc-230721014447409587"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA48vfaPAG4FpS+709IvDIpvm7CZoxPG0njI3gHRj3nOSLWUKYw5fKLBjBXRNbsUBJeuykscuBL00b9n9Ok3LAEo7QsQ4QYNzP47a0K80Jak/ieT9TPmJPN8YlUZZ87+aQUtnRIQ0FhWb8oyHRuLWv6PV37aek/s2L3TbeSZerAlbUJ2W8zV/9yHYAqAg2Xn1XGKoPwq0llopvaND+WEuID2Q1rO9Kqmf7lEPB1dmH0WLtNcaFlG0VjQ0thnfP0JPaYRWDENmZG9nIlIaxjZOAA5cAwGlTNaWNQ8KwtSUdB2cMnY/Gu2TfN6/4Z10mwFT5NCM/yXQ66RyMcsZn+35MsAiqQdNftv/xZuCZYmCJBLV8mPnFrl2H3NIT4t+HuwOel8oSQT+Sp1zREW9JakbFC/Fj2I0uwzS8+A56SoazyvnJywPMyVyxi6kJd2y+zV7jVka0u+8AIYAO66gNHr1WziePCYDwg4+THnVqb+ylZ+ZUwI/VKMlE56NZ/9uJn5UIVk/LJuff4ZNty6qSXVl5pInBiS3V/mFuzFyL+h1vpEGkirNWjjh9UfjlJQswSXRIXiFe6aWIdlzVngYCszApjJ+FYxJ5OBZO1gKvn3nQalamL/HazthrmmlSAA0kRJAszbRvXEuV0B9YtlaAva7aX1YCq1y+LKDgmhwl8BdicEUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6496!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014447409587"
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
  name              = "acctest-kce-230721014447409587"
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
