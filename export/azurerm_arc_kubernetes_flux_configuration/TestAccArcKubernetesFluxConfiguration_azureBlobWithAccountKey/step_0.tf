
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031809265790"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031809265790"
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
  name                = "acctestpip-230728031809265790"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031809265790"
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
  name                            = "acctestVM-230728031809265790"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5298!"
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
  name                         = "acctest-akcc-230728031809265790"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzIrIYknKXnmlARfTmYpTirKx7giKmY0ve7YRKMapa5iltuia9y91gY6L9kHavhVLjlba207s4mwoyRUDEK2lvU6W2W3OIbm4R+JfBPDzeHuGwBPRNxCQP5ZnVvZ96taWMpDh73933vtinE1rpAR2HJKYAQOzwVjrVxO/guPxtXOdxaQtE45nfYJZcvKzEj7eWfA6JEYJn9DFkPsXEl3UjF0JQgsFdiQ+xuuk/C6SFwp571q2bMhj2JETWvB2fagnZjbwecX2tCTv91ewg7Og+wtxmv6tG+8Xr108+rNHAgBM4g43sl/bKyL8D2tPui6QNMoPxa5CCySN7WrBPJTkHu7ykwp3UuNKgMeQWGzDZPP+5NsqaoItWfXAl10IPaxTSPlx0QXBfWOdSHLItBB2PMQsa/HbJMUY63jhqJRDPj9+uGAv0PjMKwOmTRVhgKY4V27IHGCdMk/291rC93uXbTmp5S7TD4yfblUmRIrHYKrABQfB/MbnEaD60hYIK2XRC6yjzfIMu45CweD+LZIQyWNOP2DDX2y1QsnlBg71dT7iMyCDwpXM0n2ODYPGl3BdaxHBQB642Wh3hsioM/qSUuK8mu5I+DGaOJdCTbC680o59jEAKC917kzCRpzI2Ek9ighJ+cS7SIR60kFcOBlxJnjKyb0B9QeAA1/jzTvKdy0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5298!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031809265790"
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
  name           = "acctest-kce-230728031809265790"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230728031809265790"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728031809265790"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230728031809265790"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
