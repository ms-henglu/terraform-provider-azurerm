
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033845272680"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033845272680"
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
  name                = "acctestpip-240112033845272680"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033845272680"
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
  name                            = "acctestVM-240112033845272680"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1197!"
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
  name                         = "acctest-akcc-240112033845272680"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwpIm3q0Pnne31YScKHeC++ZZmkJtVb+Gf9V/lWNqiC3DT5BNaZF4A7/YZFOvLgPfKHk3FT4dw2ac2Gg//qH1eHC4jzONwSup4qEKRMM3ItH8GrmT4phWehKsBwOEoMeo8V9tVqTuJh4fdTVcnWF/21e3r6lLrp7rcLdm0V8kRYs/T0VXQXs+aR0k+gaaVB5X2d/s8/mrVPJ8OQ7jGh+nq93pTPC5qyp4kLOUSqUXM2cqfNxClyf1oWAO4qs3lO2Yy8YxmNgTHtm2+Kr46cQ8GXXe/C+J8vbbyTFq1ix1hooScJBJF6jVFG4iZo0AH3ef0E2I48fG5ydwTNaGeStkk52X7nuKTeVDsa6uxMGeMt9vU8buuPFQkndA5Le5DLY6Mp7nGw73Wrvuzh4xe8GLFPC6V06zUA2b1GElpbyPYHHDXVCP/uw4e/hhdPTZIX7zBfmV/cR8oYxNj3hjm+UwV8es0NwJOnHTUTCo01gpx7V5rPQRnzJlAEKCgrC84qfiNWrY17XNMfBA5+BmLxmsxXv5W0L3/PyXOlXazhRmUO544S75PayalADi0SxZP8E6YCuFVyOXHWJD83IeW9v9qVddRZ6DlvgxilCqjea+StJF+vW3p9kQLLs+0TSZZlLElxbTNZ3IpMbrDcsMnOcMPbEGeXPjfWoKYV1N7rY8cr8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1197!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033845272680"
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
  name           = "acctest-kce-240112033845272680"
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
  name                     = "sa240112033845272680"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112033845272680"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240112033845272680"
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
