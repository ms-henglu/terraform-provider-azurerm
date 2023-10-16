
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033407737857"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033407737857"
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
  name                = "acctestpip-231016033407737857"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033407737857"
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
  name                            = "acctestVM-231016033407737857"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1095!"
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
  name                         = "acctest-akcc-231016033407737857"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyvc5aGsdQcQOPSdr97PTMVciruFthdBOv142FzHnx/VNR+nvCzUpJJ47jIUbiyXNa1Z9dS1fkzK2pSn/dg7XHlNO7T8RJKbKoGcKclQKcXpCaK3jzab2B1O3exm/mMvxFocHsxgoV50yKVZL29nBHJpncXqnbPzW85f9P7+r1SRxhLuci2K9B3JASvUDWDVpk/+WylpfJCqCJ247Dm7DiXELI8WTx1D4wS0onaz0lBRH42k9xgIRWJ80o6wScZFz4a/dWz/FUTg5UETf7FI+/6C7gvKQdDWwjCmR2fWUrYqr9jeipOADGsCWtcQJVDBhJcZ1at7aTbuteaKJETVxtfq92kudycXmNvmyudVI1tKKwBfHF8eAV5QXVqKnjsioFy+BsI2bcKqJDTL00O/8JBP1KXm31d/aqmjKKjT7nnvRt0vWNgPDXLrOyNIqhGbQq3lSWx5pjXPw3sbLZQm8azblLY2sljJN9rALSKIxxMi7hqZ53fUSdr0WGmvaSf7N477xj7FT3UKrrvPWGd1vNp8+wtF8lUia92+ensFq9cUEopwSW5HmWvlva6dSZvB4g/TSLedLnqutUFATrVZJ+xyy168jlAWWUPvfJl8365U1gncNdqwVZIUBhKf16hNbDvOjC7jPQQZrmxwfdPn5wypUzDhvZtNsB1KHWOjz/4ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1095!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033407737857"
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
  name           = "acctest-kce-231016033407737857"
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
  name       = "acctest-fc-231016033407737857"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
