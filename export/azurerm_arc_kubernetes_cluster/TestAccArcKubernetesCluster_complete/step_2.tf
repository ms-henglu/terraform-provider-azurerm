
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053613761674"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053613761674"
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
  name                = "acctestpip-230922053613761674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053613761674"
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
  name                            = "acctestVM-230922053613761674"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd691!"
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
  name                         = "acctest-akcc-230922053613761674"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzwtMER2YJiMYSNbEcCxaTe7ox0sv2Ekc9USCe9MQ9EO7YThwRWgBviKlDFqExxws1Ml7wCIAegi1awk/oF0SO46XG3AvmwIYKvjloz8vgph+extbMVEUzC2vyahAkJNg9oya+mmy8LAceRitNA5j/8OsS4GtJCCmo64WxSd9Y/0lFYh25u+WYG2fPDzrjHA/j9gXFj91WV8mN3iHBc11d+3qNp1VmibuE8WlaSrtDcwRyruMAkbW3vi+TsGG4UXhy3deSeZs2SdugDkNDub4Lf3d2N3Nel3adIM2QGgxdS8HN+g/eIxGKUKtAblPVlzvUrpur0Nq9fSNpr1nANe0OCrBo6MEEHUr9wRyTEm7M+4Si3OwBCC/YrzIIm9m20kpBLNH1cCDTL+tmxtgr8u9XGmUzHPCAGX5QKxY/08DS5VLETF2cGTLlviPwoOTtbC0UcS3NzmYQXnwcvjIbWCMvEsiLUZUCLkUx+9Bx8HKZcQfQMM7c45Pm2A3/xBDEoim+M6qrGaJWhjxuYFmBtq7j+JnePv1bhXGRvnPRQu8hfhgH76b8D+LiT4zcj/LvLPUjPUSYO5PYDwYTT0JIl0eH+vmcyzx/JygrkF7Dx+/pEUapTUUGFxEIEmn6S3EsSs+uSkfTGvhSl7bSXOJMwGCh5Tep+bCAcu7/MKXw2nwPMECAwEAAQ=="

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
  password = "P@$$w0rd691!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053613761674"
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
