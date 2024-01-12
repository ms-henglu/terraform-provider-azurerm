
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033824663363"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033824663363"
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
  name                = "acctestpip-240112033824663363"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033824663363"
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
  name                            = "acctestVM-240112033824663363"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2350!"
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
  name                         = "acctest-akcc-240112033824663363"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnyXZ4EAeJ7b7b0/lWkpZNKoOw5+LrE1a7IcvOHdaFJly5ZGRIVwYhgCT74kELzUnD+17gcRcCeteS8ASsQfJSQqbqlur2Oxq9DHBGsdObGpX6dDbtJMpbu1DlXghXHfG2S3vyT+/l8qf2IQ3rTdHr738VjSIASccPZw3jLQuT080B9Uj4Yc2apxKjJhWuAnheH6iBjwhz2iXDg2La6ZfR+7L3mwXEDpnezNFLozbgGdU2gNqJqqed5L63TdsmlOPXRiyBRYw35VZ5XOg7vy+D8+pHb4k8FfN6wPSVZXCvsVub9IByNJanoneHaXFmSJk116ajvrrf69ug70tz7Rjxw7e0KiII/VCMlCHC2WksPUYYjT6HEYDTeciPJFqUlEigyyIZVgRZS1JnP2Q8Ukb49Aj4F5w/sD1xsAYEGygNfw/grgtVnsxO1Y/8nlWPBOxz0BjtE9d2hCOg0sOHzUaOPr10DdOoHcDacNdTYRiWShhCkWvxL8JTJCteKjO8Qw4b3Zf+UEAl+2fszEqID2nUkTWybfLY3hFL6JIzqzy8jgDwMjJ76HVZrG7WEDFHa2kb4nubb6n8BuJEfp9b86Ujf/LhmDhT0BYnuLfgOctCMR8TSpLXa+wGpv8rmA+kQtuM9HNE8u7JjbApxufqAhPX510iDiBgH2oMOxiXhji8ekCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2350!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033824663363"
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
  name              = "acctest-kce-240112033824663363"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
