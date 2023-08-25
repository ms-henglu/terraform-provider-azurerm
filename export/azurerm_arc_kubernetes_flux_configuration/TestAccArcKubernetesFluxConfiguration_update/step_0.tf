
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024047521545"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024047521545"
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
  name                = "acctestpip-230825024047521545"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024047521545"
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
  name                            = "acctestVM-230825024047521545"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9846!"
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
  name                         = "acctest-akcc-230825024047521545"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtBn7xX7IvmFjdrr0gldWbmETXALTfyGptVMK8CjlzBSMg5FeG53rdWmx3lBDxhWfHGnPWf4EukbTgTbzBGpc8Zyhi0gBuCAuKvCf7AOiWbewdEPpzvLXg3Rny4xNr+pBh2erVeJ+Mifkff2T87uIImqMUWa8hBRsWUcCiz36M8cJQSlG1cPnC2IsKoQSAetB6QewJLpjQri52GojKnDkr161uq79mEXEcocWGYhe6IBm5IlGlZAdCddZC4eUmfNzrLwy1oT7Inm1dDG2qlF7X4KAd/Qf5nVzUfm3icaBlsnaBOz3G0eFz28NkMQ5D8ff5Nv5iaEqGZHBTLe1hfbsSgACGezYV6ERPTb8dIUtLwVxwL6P2HggnkFpq7Dh3NroLEmgHS/iutlHA31QA2fPuHmsG49wVSRajRnpwMRpU551iuq7EQxLx5RunSz3vQYHUL1hQteP5i0jpeY5Zyx6sScEy38rgrcWPs5SunJGERSzvSm75Y0IY8p0XD4lskZFFNjXM6U3oXczEGPmm576vw6yoBTlOwAQh1cTuMplcjU8K8tYj9Hr1kNQQQOttSVQ/prNGXr2qoIuRAWQ6YYM2leJ1RS+UwrhGI+JZ4K+K8bOkEFIUq/e4JniLxuHFzHKT/aQ5m0SbQft2Cfj032cnYeDL0bZhi3sFBFhrSImW0ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9846!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024047521545"
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
  name           = "acctest-kce-230825024047521545"
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
  name       = "acctest-fc-230825024047521545"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
