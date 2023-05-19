
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074203755435"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074203755435"
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
  name                = "acctestpip-230519074203755435"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074203755435"
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
  name                            = "acctestVM-230519074203755435"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4619!"
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
  name                         = "acctest-akcc-230519074203755435"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7SSEc60BXc8YIieW3npe+aNy/6V4XhVTgrn6DFI9wooUkwHHgDJ0moV8iDcr9M+ZoaFLMByNlOEOeLnZxi+7TVXikBNxcUDkTUUNfiTdq0CMjx6TK0UKeYXg5UifR0OYR2Yg/b/A/PXwOju0S39tpeJ6M65C9j4dR8qcX3/mTSZAu9AJFXlX93SSYiewdFiKjb70HbhHG4yrC+zkVXiYOfRTwoKBOzxe33qOzt7xEA1NSkWrvlMkVUNDgGye7j6Y2ttHL0+hF0hSgsAlxOMUlo36VBigVWx8wwTLqsn2s7o+bg6b6C2GNI3BE9NwFhKDW23TvqrtmU132Xs4WybyX+mDx3wTP6SV8CLjmgTK5VGr2ir5xY76p+/sAnYHsTpv7pL0eO8x8aNeDSbnVtRvEO4gYvHDi6rYZqB4DPmLbCK1fNDiEh0NQfRRNI7U8gEVAFEyQUHqdqFo2zWVszV6V/IWWF6jF09WIgIzimNANNqNOWcD3QXOcxwh7cp7vZAkbbt8hLGT4MynihfPCSwPGeoJSgCzoc4yIReCpH/IGMmLfPUK+qKrIrTsxiT/NBiJj+olQUvkMx4uhtXT70/JFfAUYJfPY4+LszXobDc2/oyQVgIKoHtlJfXXh64eyUpwvq/HPPxgHsYitpyA5TeiAXQurHCks/KSvmIPCGwyTb8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4619!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074203755435"
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
