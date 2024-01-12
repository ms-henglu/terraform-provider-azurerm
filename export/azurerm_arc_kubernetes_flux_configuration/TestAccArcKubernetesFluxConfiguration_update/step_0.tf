
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223945935028"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223945935028"
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
  name                = "acctestpip-240112223945935028"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223945935028"
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
  name                            = "acctestVM-240112223945935028"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4200!"
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
  name                         = "acctest-akcc-240112223945935028"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0nNaRisVw7fFxhUuQ9ShvkCzkvacZLJwXNF2EVQk7ylLdxMMjsa9YHtQplCR2p52o84h5eiLbudXH7LsDinRu7id97Bag4qAfpNaxr87oqQyXO+y6qi9W+kYL1QnrW3E4p5tWA37S5+B3NRkixPvL1V4AelZGJC2over6+9XumRDgIGm0QJ/6x2brzMay2KIR0uT7co4R1xG7Hw3bX2cP2a2Vkf9A7xVHI6c6fiv4tGir+AzyZ1Dn3wwzYPgY3eHrY3w10VuvpNLLybOPyqy1DPWuiJVYDZyrrhpMf7zxVy2JyqhPUuNaufOEOAyQkxhvayXqiaYBpWw8iMdaec4svF9li/D/eLGykISW1fBjDQoOhl0D815u81yOwXE5n1jEYD+G8KaiiMjd4g1xYPxHGiXn1XuqskJ01tEXUE8LtLhT1YgljO7NR4p71L5/pf18Ey3Ds0xoSgQNQxR82AV+PErdlnfZ51SeD5FnKLZ+lj/+MEoo98acDw5Tzev4Cl7YirIUZEJIZGJDy80wjskwbemLjwQHHMsyNOFl5tYGU6Qty3WuUWuKTCaiGrSPIC8XpNJwLDJZAdqH7Xv0Tn8TmuvrRH+BaneyrWGiCARiArdQwD/TQDUAXmdjv1IDcaEb/uvoTuJIkuDHWpmxIKdnk0eDircFa3JsjQ41xLsSWsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4200!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223945935028"
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
  name           = "acctest-kce-240112223945935028"
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
  name       = "acctest-fc-240112223945935028"
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
