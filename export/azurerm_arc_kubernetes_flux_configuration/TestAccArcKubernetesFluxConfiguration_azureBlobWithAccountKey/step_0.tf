
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060247927918"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060247927918"
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
  name                = "acctestpip-240105060247927918"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060247927918"
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
  name                            = "acctestVM-240105060247927918"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3025!"
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
  name                         = "acctest-akcc-240105060247927918"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5ARn1N6HDbwutGGjzauUozi+3/KmqDBkUWkQ4KI9aO2Wi+tLg7pyDBUsIgJ5E0ynZK9w2BT0QyBAVyHQftJb0AuLjAq7ITiNozwx9scB1+RKDIv6IUfSJFWKhtBGJqBEnSP1RqxbXyQYWdOxN3nEHMOEGGR5YbZg7E8pQQSOB31oN9BCfxk128dTJL36+PAaH4q8ZY6jOzY2Lb1gjmeMHpcn5HtbqYCm+CQ5Jc5iFqziUSlG8dYH2MRwGs61KHERa0WSFY1zqmSIJcHcNtDXJ2DG053ibj44apLgHVTTvpHZUhkSRQR7zr0oKW+3qNla4mFHbSKSA1oU0//cjidcbQ28ylvji8GIeoxf0XYWklDv6DIaefvLWudE2bEwGSgjiyvp0v4rO2fKviH/AZspVzsIdjIPkD20x/2thrxVH9GdVgczDg2BAsiB9nZKTzDSwvGPX1wYhZVB03MQBGJ0y2/tPmgUC/CPMMh9S9zZGULnbXUaKgUgiaap0DBwGDhkbsPqhyx53QYshVOH7Ey2tTmGu03A5yV5rSTP6DGAavXDLcNTckTl1eMyMDMUnsU06Gt1bQn5UwH+O0CN5Ovkr1iyi19YLs/amjuRf82r06wzHeN7/3j0QowFJhnQguRiZpamoPrGxltuBIP8ujUdNagaJCEjcn3RXvV9PBraNpECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3025!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060247927918"
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
  name           = "acctest-kce-240105060247927918"
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
  name                     = "sa240105060247927918"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105060247927918"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240105060247927918"
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
