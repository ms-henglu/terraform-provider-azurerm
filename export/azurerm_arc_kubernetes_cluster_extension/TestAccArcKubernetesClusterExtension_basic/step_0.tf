

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071213658591"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071213658591"
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
  name                = "acctestpip-231218071213658591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071213658591"
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
  name                            = "acctestVM-231218071213658591"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1355!"
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
  name                         = "acctest-akcc-231218071213658591"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx6Sxje70pn0a/2xkJYMsmvnR37UxdO1EJmj6k9oor5uvaNIYTlDjJzNmhgXpBD+1D3daTr1xcGRTvqb/ORnd+tgXt1J/NPxXq5iVWK0XBT55enk6o5E+e2hqn+MqP69kh7tbbpTia5u7i7iFDozwzIXKxQo/qZVVhce8K+kb527n1uoVVmU72YDuOMF7TTZB7vq1857fxe0TO4m2G/re1dr/BhIO7sJF/oLNJY+oDOEy7D2ZqYf8pyuLmd8PYDE7ruFP6IVWRXiHxSXcsc7n92nanp5+uhjhi49YEGYlkiLdtoM+JLzokH6Cwz8lv92CWs6/n19967UqdF+QNaI0P7GaPXQ4/BrKlxure6dsMjMe3dLgibF6EcFXJnZgrr79q4rsYP28fnBzeOSqJkYiERKFD/ZIQ+5LJoBsNRzL/Ip330/7kR7fXwLiotQUmTQ8DBUnBTKB/P6IpKoaGK4y/vUXMDcQGiNPAJ9pXz28Z4rUpO9WLNRrSKsUMvmfya3KRKRJSi+TpBnD78keIf5zG26ovwag2v/sZ+qbwLUacLvxg9d6srxZEc0FOLncGQ5EJ7eYyozsUYdnYSpXgVBJM+JA+ksItCa0UeHT2ugx1Q84pjiRQak4gQkYKc0dGP4p8V5oapfw9yeVTGborA7H36XpmMvgKu8aFAwzA7LqxbMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1355!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071213658591"
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
  name           = "acctest-kce-231218071213658591"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
