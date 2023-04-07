
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407022909567201"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230407022909567201"
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
  name                = "acctestpip-230407022909567201"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230407022909567201"
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
  name                            = "acctestVM-230407022909567201"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9427!"
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
  name                         = "acctest-akcc-230407022909567201"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvTv9QSK6AIlvGLpBRlTmqBLvRVEg12qdWYR9p2szrieKBzbAb5Dk7WcqLb4z65puBHtNSV2/YtUFF3imNRK9Va89OHkSFpXyt4buzJdH/AyJkDH1UpSd+xxV53Jazpu4sgKHdydxG4Vm+Lno2mwF3/twtcoIb7HqjcLbU/aTjwOuRl3FfF1dgFy4Z0jrbmwmuji8ti4iNHPPZBTv6SeadOMt5nxjDkzgKqglaq6f1YceZnu+WLYG7BY96D8H3nm7aUb4sWPiciK+NnhCN5TVUGBziUfY+LW97j09mcR4nG0POjGYWD6m37L/mr7Tz1Vo3l26MODl0JwLq/gITTjebCbpAJH1bYxQ2wONW7tCib5IQn6jD3SkOcZXujNsgZMSHu+1c+qvOA6HgvkHPayFW/0V8hvDPSZoSnkLB5NGeiBQkyc2BjGvjriELtcYQl+rJC/Gt0IdGqCGC2lm2xrHovCehb1WPMPjeQZLdajdi2oh8/NJEfw0lJ9B/29aXQQRCFukJuCBsWyN2fJ3jbWeQLZVjlZR4nIO46uEv49u94pEC7GeebAosvbZXpf8jsuAWK2gNYFJEL8HzwzxwmP+IBb3uyEvKwpcZQLKANMZ2BX3YTyHCG9Frx7YlqKMHPnQr+/yBwfZSu61U4YNhbAdvm3uAeQ0DUvlk/iGPyUj/DsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9427!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230407022909567201"
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
