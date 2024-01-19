
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024513268710"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024513268710"
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
  name                = "acctestpip-240119024513268710"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024513268710"
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
  name                            = "acctestVM-240119024513268710"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7334!"
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
  name                         = "acctest-akcc-240119024513268710"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAquIV6h7Pi6n6OgwPJTOIQqcooUhRbwBT3WviBEETzFVuKXbBHEObe4o6Qe/InmeLmJaBolf3LbDtbQTlKyXuiQXejVi9/hLzT8aPCRxDWmbrF7SjzMsJ9YP3ETrFMxKzW90B/TnNOa3unSZHSDtIOPFnHlWLWamlHOR/r1YTgX6VeNUxtyXMx4F5wfB3FUxO2clIScSVtOF5AvEi80FKJpCvEbOyXG7/qVVN00BnE+osiZRBf0a1X1MK18WE8/SE4IWSQ0SZr1Ge1DNfoFo0358AO39okl+iv4DB4g/IDG6dKW2mGIUuYCgqVQ+TQ0C/4L7hRlvKjjwETLdQiPfkrixM+bsFRfX99Nf9Qmy9md8jQ8FbyUsrz/MhVtxbQ1O4zNcwJPWjZVZQSAgDehUZCsI5YEOoMiKVhsAXg17M9fPuzgEc1ajAMmPAr5pXr19L2U3amPkrWnEDX7hcHClYb7iqfW0ZItFxmwxlY7hAg5pmLjZS/+JlhrEOxCBrnOhvHIiPIb/HpLQ+CXnFwkl6JFqbSfHgL5/F8UzmmohNNCzqo32TCbEnvvybWYPhcbpYOGEimNSFMZYyx4HT1Ka9CuXtiGdP1ptBA+SX8O5WmbHdyrPCUIOgLYIHLgWG9FwaBeRNcTcBbiwsMVjWrB4lkOoopG91HcAoLXXuw7NXv/UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7334!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024513268710"
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
  name           = "acctest-kce-240119024513268710"
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
  name       = "acctest-fc-240119024513268710"
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
