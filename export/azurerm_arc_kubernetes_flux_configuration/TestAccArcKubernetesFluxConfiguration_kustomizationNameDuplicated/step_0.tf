
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042930302428"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042930302428"
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
  name                = "acctestpip-231013042930302428"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042930302428"
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
  name                            = "acctestVM-231013042930302428"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1851!"
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
  name                         = "acctest-akcc-231013042930302428"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyyq4CeyhPEswsB3bEMl9VKSY6OtC7pD5jRv+iFMvelpvVyt5QsiWL7ZBqgp6MiewXiOys2vLUqgYSCaDD2HZZiKE/P1DUCkPSkOkSanf013QEnSmndwdns83NcVa8G7qo+bJIWxgh5VAWa8tk77Aq9k94+IM+kEfeGrz6shc3UdFRY6idbx9S9Wn39+sh0TRDgvHRs2UEpd42RDE8ORefPz217oUd7cFL4pbp4/mAvgeSVgn4bxoscjpYTHjPrJ6csaMk1y6//g9DI+g9H5NNMBMuL2w/tvhlEdYx03ZhCHCjnQIuLKHbNpkkteNr+XbNreS6HFw/SumbDdA81IcvhUK5hH/F+8bzObRaQwYGGuwgFZpUyJBmwSgbOlbHdd4XPkeqjUQHOvn6aPJHno52hMKWOeZlLYqnJuNQI/9uBsMF/xPjq38we24J/E8RWYqSJu23o7gKtIda9exBPdyJF7LWIxb2mKrUa7hViyxwo+tWeAklzDsced1Up3ULxssd050sJTnsxPwNJWoJpwiPGj7t1/gQTkZbZTX9EgopHje8iPEP7rhea9oZkNecI1l0dkf4HMZFSYnpzaP5udNDblAnH4LCTZGdzE3iP7ICFMsHlR6yzHXarH/D/2UVL+vXyfpdHHmSlTMGsE5IJ8qUAVi4Jhx84+moFlFluUJmXsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1851!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042930302428"
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
  name           = "acctest-kce-231013042930302428"
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
  name       = "acctest-fc-231013042930302428"
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
