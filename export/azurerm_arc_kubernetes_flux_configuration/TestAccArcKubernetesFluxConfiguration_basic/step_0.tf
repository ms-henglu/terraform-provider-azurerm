
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025054142873"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025054142873"
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
  name                = "acctestpip-230728025054142873"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025054142873"
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
  name                            = "acctestVM-230728025054142873"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4861!"
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
  name                         = "acctest-akcc-230728025054142873"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzfxqVooo7hTkNDgaS9NDVKMVPGCRSMN8w3Jz3DhuXTeJn/tkMQo4JDAexY5wFbvqRL5YQOvcSGwQH5/q43ajrfzIOGM+WmR68qLQz2kuxDamkJdt1q8Vn1voLbhAePb9aDPzKQwkpWtZVoo1/I0aNq5bTgps6GzMj1fwb3KFg8dB/+sQfy+Jq2rt4CNQZOje+sCCjT2BJKrPOTFAENEuMgj1so+ODc9yCLjfBVkIRs7KnUFpARKcrTVuY7ILnNDTalocMSTJ1TH5NSOy4GTxxX5T9x5bQxEw8hN+7bWkL+JJQAdA4TX6CNGLZXTSSKi/d7ro6EX0jVsL77MQfw68QDbEbbr0VN/f7UKfSQrSXX6FhPZpURHclPfFF/vhmgKeUHrT58Wb8mBgCH9yOZg0TXolEpjn7X1yG/xh3MTPzdp6mqm68cY27R6MQabmCKMt6lk2n7Nxp+TGSZw85TiNt2oTBkrIj+0KnEqU63H13dao5RXowFt/oOuT7kyOpG3YQfAdnvpbdWBin+TFBO1DdE1cs5cPi4Dvi9z8NXjk9NpX/yFGXMaj0bC3RapVpnnNpajQVK6jq4FDZa4CW6SMU6gvDvY26pTDHPsTJ5fU+ykKxCgizZa79o+ItaIHl6CTjAJFmDzcMfSUQyehv5odswhMHeorsZQYeji9ZSZD3PMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4861!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025054142873"
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
  name           = "acctest-kce-230728025054142873"
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
  name       = "acctest-fc-230728025054142873"
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
