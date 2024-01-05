

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060226542735"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060226542735"
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
  name                = "acctestpip-240105060226542735"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060226542735"
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
  name                            = "acctestVM-240105060226542735"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8797!"
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
  name                         = "acctest-akcc-240105060226542735"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnF8yUZRBqdN7AJVrOomvWRhi9dHWLbOs/VRNpxq91djIepgMNktATIkxzEd524P71sQIiRP/d/Qo4kcp7LCK70lFOd+PITTkyutCC/MbpeTUkYwDUh0jlo5x0Lf6nBRbw5GJALeKuXJXjIcyitYFh0+WB1ZcsrE3flWi7HF4a+KGIarBAPsX2tM0ozDCW5f/P0nrMMQPhvLYtSycIh5/3TgJriMqpjf4CAfgIWe7yEmxJr2+dcFrYsVJFIg52k4Zi9WK04FX65WGKDkATprBw7xvAp9LImyxZE0W+ZUmXxVyCHoCIFwyIh7WX4SASSpDJk4rfNccURRjk3SCePM8cmyYDNiMsGg7LmomVEkfHxX5gMcBnaauA0IdZqkwvP7JwHnsIw64PXh6n4Ps0YWBp2BpUh/WYIzUPVHQGRp5I7c8zAp5Pc7/nP45mBeYHG75XM/Icvx6xiuEd0YYl1HN0jgvtSC17s5+ZoUVi0hPaOfCdRk9T/zSGqD+l9Jqi2awsSvJZUlT0WX2m8OLTCIncIPPSo1kB5oBw42rtyz5qkvEUAQPP6BB542Tas8S3cSwR81po9eJnXrKKReVPWDFrLTj3FoFtuNOKTcQFpGY53GoMz1mMGzk0omYVhtLysuIv7tRt2ubwDd8zkEGTqM+TNyK7GKT9OjjY/1DzBc0N1MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8797!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060226542735"
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
  name           = "acctest-kce-240105060226542735"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
