
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040542812267"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040542812267"
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
  name                = "acctestpip-231020040542812267"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040542812267"
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
  name                            = "acctestVM-231020040542812267"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1884!"
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
  name                         = "acctest-akcc-231020040542812267"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApnqy+Pn3Je8JjmKrb0S2zbWEn6Lx9p1ldoeMGkk0lXy2QrbuKKtvryTWWDtH3JOvoJMvcwlZ7sVLhnUendyCaV8UDQCFYJxStqIkAS9i0ziZ9LdsiSr3XdKrUIF4hdYjgtZS/X3xAl/gPJcfcnxV1wwHjlqgAqa226WGzzMlOiQhLMLfim7y7cxZXrcmyyL/3wTJPTtAbGbojRgLFwLKe6+wZKI5CBtLnHNI6yQLtPrkPEo6cyFQgS8T3evIjXMB9sV846Hy3judivCFO08f2yiE/SMbg1jGKNh/gn3tKqsQSH0eNCMNyyG0uW/SAT/eGXDqcI4+kuKja4s/o//dMc2Rqy5J5uob7LSLHfyedHEbLpC+GrwKijhqGRThZIgiV6pmkyN8328URdgboLEd5Ia7/dnCbn1jtjrhMJ6aQ231NT/4djpl24Fb3aSzj1OHVNprBqmZquB6u0zEQ0VOjfGSxt9z/+Q9KPdjvukd+w2/XhmXdZ6ywvL1iexsn+/Eng+mi6R0r9AIBmwW7XyKBiU0sf8jhA7KEbVTxcAj3XssfVZy5xdMPwMBtBY59EO/RDTLTItQ7Rb6MozO+z1rK9QM3Y9tpt6mD8CJEzWE1+H3jApj9zTF8T6xPpRn7TIgd6fjTuf7Yl77IZg26iVzwnAKfI+k7nBISM1Gd+Zvux0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1884!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040542812267"
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
  name           = "acctest-kce-231020040542812267"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231020040542812267"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
