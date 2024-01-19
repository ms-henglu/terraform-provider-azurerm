
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021520713579"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021520713579"
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
  name                = "acctestpip-240119021520713579"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021520713579"
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
  name                            = "acctestVM-240119021520713579"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2278!"
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
  name                         = "acctest-akcc-240119021520713579"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6kSBysp7tKZeXAf1DkFQcr+FM0vwJFPiip9AAisNKvA/itO/xf/4rvLxL52FXR1FCsRgMZm8q+AgbSAXHj2YNgPjcqWej3tNhTPwtlSEdRo8qJyggXz4a9F9o/EJpV1TQbx2X24FmmEOuBC/minrgN9bvAun/H8TLFWCx+2EMNl4FxDGbQLE9BJxOJazIwdbAvvmf/OG/oL/gson9bpXN9cJq1m9fcdiiTzel+JO190jTX4V6VD9xQs1nbvfwcuYECf/D8sggccocVBgjg2z5pYhvIM9BfQSguR0y+4XUmMu5mQLuIAh1Khe/L6SqBU1f5WcrXtPSyWtZyDXvVYbthsL3NBShMDe/FqBLqkJ50Bgitt32SeYYhtVbi4HdTy4h2NAm4BiE3jx21VWG2xy2F7MpII4RIB9s9rsWNefZ6+BiSocHh6BXR1dtd0rfLpAiO9YfhHSHsV7mpXbSxx+jHb61KcNogiQkz4rfyWhCZy890jI2PNieYhPsvP+9svqx3dOuPCl0OVdXCUIqMQ8w9F0LXXoz0zAuJAS3ZF8u+eEEiG5EQtlFBZAxX/FFXydN0D+nKhiEu4ZN4fWz7TidBW4VrhbkhmR7nsKoqCaGo0rAyqC+J4tVV057LFpdc+Nu8hQpiwcp0xYW7IC7EearyBFOOkEUbNcrRHktakD4bcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2278!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021520713579"
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
