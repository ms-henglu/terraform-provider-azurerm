
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060242818958"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060242818958"
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
  name                = "acctestpip-240105060242818958"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060242818958"
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
  name                            = "acctestVM-240105060242818958"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1759!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240105060242818958"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0ifKpBlm60jw6/NOeP072G0HWKcQ4nUezHH9r+VCRCwBY56najHRMpWfU9BFGP0xPfmml6PEzCGAfXBnljd63xVwWcchQJbFZgBdcSmd2PlM3BxNf+IPrHiow/K55WsHOM90/z5o718zbz1AIbLDL1dW0y+mNxMv0cyLiXmVsgqC/HR0Jf+wYlwCzspsiAx+/faMrIp0P+4F9B0jlcX7mPVuPZxYBjQsiZM4PG6mjAkGKJSZGxxE0DgtjmU+abETDIXPBl2rJBbkjyBI7wI/5aXzOvLeSfoaF39L/2mPdPhPo9BEhawAR5PzXV9FidHYG5dwQr9lk5BDAlxSKYiUvGTYci642NZYc39PcrvO9WGDedupWU8b8LXka/U38tPLr3yy7mmxRQP+PvdPy1yeo53TJdADCGWz0CKmY4kHvI92UYJonRvLgoA2eTtG1a4HV+E843hwhSbs+dEkVFKeXYJANlmyvJQyPENzCzI6GGKijvLDSQ1z0cb1+XozdEZVrgAM3L67DS+PwlVJTvRVvoLN6FCFsAvbZVq4WjESexVOU/rxq/jYFojUh8A5p/Xim7zUojKygMzNFBJVfhnZTDAzpEUJJfifBLkhI5P8kTGwcsaSA/TN0qH7kyBC2HA9Vc7lj/OzB43X0J1fWcqm5p3bzb9nfrHQI/cKhu9XnckCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1759!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060242818958"
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
  name           = "acctest-kce-240105060242818958"
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
  name       = "acctest-fc-240105060242818958"
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
