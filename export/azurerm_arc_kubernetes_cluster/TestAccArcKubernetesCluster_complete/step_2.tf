
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223934940721"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223934940721"
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
  name                = "acctestpip-240112223934940721"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223934940721"
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
  name                            = "acctestVM-240112223934940721"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2684!"
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
  name                         = "acctest-akcc-240112223934940721"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzz+RpXI4EwmoI7RStiEL6atdy5QK6cunHWUrZFfnifo0pRuZbUG0DW+Q0hWYlMIlX7LGCU0JUCN16IWlGr6+GpdU3+pjeGO/dDMo7iK79qZsbwSWeoa3gLaEZ+XdhZqy5za+Z4v5s0hd5H6P0q6uNUjoCpAhAt05p0UcGQfgkaE7vqBlkXmdmEyW8EO+JA8bVhq8OMBBd+DM5nKXAFGlAYuz9HWU+fvl41DRk/144WZKwNMGwNiGMHVVj+1xnv07PO96bdQuTXWH6SMgZMqdfiKMl8jQQhvimibIua3o9yIlRlC/YBdnDmPCW8Rp5e0getNQ17R9VxQTsuwwvoYi9PUiLgHghmP0M+Z/ywpUugu2S22wgBeY7bN/VrSqfLEAOpQidfVVU1ukX0sXX7R2YAJXgmAfxhekp1nzXE51gm6oJH6opIAxwRmBu/RyiH9GqjDYZvqd5ca133Xe5FvxWqigUbLCJBMiVCGiGr32WLcyX5J32xNc9Tg421ZhcbuO3fs0k8CRwb4Y9n/ctoQnri1qnThsGgBMyYuIOZxczc3h2vF4Pj7p9gsQhI3ChXY+gBQc4YN/hjH2f2SSOqjQDf3FGqCKwdDs8Vu6BZImDO9cHqc/sNppo6fPO7KT3Dwo7XPqqUXikAcoj0znCJrLLPw28hV0K7g0fmotCT7RHBsCAwEAAQ=="

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
  password = "P@$$w0rd2684!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223934940721"
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
