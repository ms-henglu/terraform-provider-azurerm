
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064401497115"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064401497115"
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
  name                = "acctestpip-230929064401497115"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064401497115"
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
  name                            = "acctestVM-230929064401497115"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7076!"
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
  name                         = "acctest-akcc-230929064401497115"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzyc8UDvcb7lQ3j+McS7pgUf5J0ANcsN8S4HnSYVEr3maSHisEGm3VcS+g9bBLmwZk9QBmyTx1QHpq0eOSm/KL6jqgza60/WfoM16ttaDOBKn30HB1I9nBTMCwl7ujdIfm6fClTRS0dZHtQvrw3W9iX6DNVtuoWq4Xx4QIkY0vVo/LIf2vu0r1KRgejIsodMPB2qLd2YnIFDpbBnBUC3g3QU7sT4+uEKm7fsNWxXgSrunWVs7iV8FN6iK1/QqVl85B4SaazdWPrxuzJOZdLaYYF2YOOwsvVpHcuJhScViS/ugJ2ZrtZ7TfrsK0L2yC7BowdXQsWnqcs1KkvBkSvvM90B4UmB7qXwUBkLe+fTcHnQhwTivy+N1xk9b6YlIDs1TSC0diw4b2eUkeG0snKGHq/+xUwKPAMcKZOtUL8ykZAS2jZta07/EMAvQP1HWZzx7NckLZfClqmwUfa+aIZbC9YZVjH8//J1RtEYylB0UJUlhfKfksHKRBdj/W7WNFaXZlYDeIxNfNMM21p3U9uGYM0y3B9fhMVYe7k2PLQ+4bqRdHNLOFP/HkpDp32hc44PWNI2Pcm2QrBjyHGG8JaUyXTxehmaqP5BV2IQAOBGdkpFKjiHoYuiim9gPP/M1s7NC9UHqEzF6eccJluj5APVLXETQ4nxM47232hEUXziA6L0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7076!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064401497115"
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
  name           = "acctest-kce-230929064401497115"
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
  name       = "acctest-fc-230929064401497115"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
