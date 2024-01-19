

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024445736168"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024445736168"
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
  name                = "acctestpip-240119024445736168"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024445736168"
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
  name                            = "acctestVM-240119024445736168"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5740!"
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
  name                         = "acctest-akcc-240119024445736168"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvXh8zK3ZpyXwWomTDbI9uFEer/a6bHMwvJ0BqJa9LxFiGW1QjzxXI1/4bxQoxDZxwaOWNR/QwPejULDTL7YDm/nmUWIg2griICOUduPaMD2weP/HmHRQo2XdnlV0QbnpnMETKZSWHoCRAz2tfDUFNEFuUGUSe3KIZIJqMKKUZIV1MgtjPn3Og/WzKlJnMAr+bsAq8kgw36a1PH4zdUcPv9AZTr0MOYNS1ZUZSFPZ4PoD8WQZZ8hzIP/qW0fj5pZ/I+StHPlACQ2expZKs6fqxZVbIj/FUESYQ4gYKMI5wsnT2lt6WBBh3MpOdUJA4UI8gaO2eUGbx241jfXCN/hRabkW/LMkmNO0x9weshDDCpdLV2fXlOWcrnF9gnbVThVuby8JGENp7pifNUeGNRGscP+NXbXkS8iNvnloJb48wUrJ2S85KTtNt7pvQrgV72OMyTYB9P6O2tbDi/8ciGnxC4Ui8mWX86CHU+ASTCL3GBWd6stPz34XN3ZnAE4iEbB6OMJ4K+LOjOXVxA25Hf3+56Mra8QseiZZR4v5LRsqgP2DoV/mQS0UbR+734raXvR0KYkAf4hEMYpYdyT5+3TxyB3RCGh4uaja5qSdZEDmB+OTOabqtMw+Vn90euVYXG3HH8rS7XoYKwJdJffpt2rc9+5MTz5I8QaCheBUW9IQSzkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5740!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024445736168"
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
  name           = "acctest-kce-240119024445736168"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
