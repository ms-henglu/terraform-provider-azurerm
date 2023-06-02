
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030136768547"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030136768547"
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
  name                = "acctestpip-230602030136768547"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030136768547"
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
  name                            = "acctestVM-230602030136768547"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2760!"
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
  name                         = "acctest-akcc-230602030136768547"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4NZqUvnCq8tLFXz/DoJGYCbjMVFmRIUPPHMwOTExISeAZqetkVJVURykE2w7JhEoJTZx9F6PMcFNYKe5moHCikXSAmM1ZLH5gZxfBcTFvKHPhGNE1l0e39lN7BtAZN48Oc/xbIuuMWvCsSjwFIP/J8c5I8PW8v23LeRuYmIBqH4p2mKCeL4s1OAZBbWWwsqDrBY1hz5/LNBec5UJw9NDqGxyYdIww/Gi3TDr3PdotAa27jGXT9MvB+d+kgzbS4ZkIfypj5YZHfcAFlUBAmlI6KX8zz2IUMbYksxBqj0+k+ls+2ixw3dA81hg8dB/y4uw0EgRUn3kU50GFLgSPw7Eq/bGZr6uLlrwPPU/r3vZiu6D4oALB29L+a6NSK6wpfzewnMfg32ctBQEDKMnJnHc4QVUMwzQuyrUgBAM0CvIha94bYqgLruYQA1s2Jzllm8oT2hsjW6fFmfgVWFDhpE0lkexfplWa/mLc9tH3hNYeBepdddez/eRJ4GX25/Kcyk5iX2tqUF0nvuCvJn2PYm4VI3iQ+b1TTXitJlJJpdKksCNgzk+pl2MrLrrDft8Ga15wzZtqPn9oOrJU4ylw+Ee48FzFsHcEWjV5T90b6HtvdSjBsbyhRIyTJK2mm3o7wmN6jvsTtcLJAG0Livp+VijX4F41tgmMqniWC/Zzdv6GdECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2760!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030136768547"
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
  name              = "acctest-kce-230602030136768547"
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
