
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003424312284"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003424312284"
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
  name                = "acctestpip-230512003424312284"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003424312284"
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
  name                            = "acctestVM-230512003424312284"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7298!"
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
  name                         = "acctest-akcc-230512003424312284"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5hNdUCX4uE0p2kwx0pVLjMH+vTN1aIV3DH8EDfH76No9lsbHTyieRmB1f3eEAB2lIsVqHv0+IJ2CxbAYH6/cuLO4L1Q2DHw/pnrBDUtEJz9RbS6lXPOFBO+JPui4qjqQHVyov36Cfyty8NgvOBrjep3xkeIq72xflwFp4JRXo51UvbkoBZ+/h93Ea3ay/LQ2PKqEKAUBuAR+25lpTEmNQVQhHlzcVlu5T6PDKiwgCTYIZjQoNZhtI8gDiOSUGF8xdKXG5MDXGYCRkYIXz7GG3alXDy4GG83b7clBDOgl8ETr0FvHu9aHNE0YNofVIEbObZxk5d4qrbg5siI69+ZpK0SeKuRDsSQOoF9btezD16Int29e/Jg4neneFdKknroHYhWnX6EdPvYZi6wS2f11/Sr9Xv4aBLXDXDQWOmURVMOwwDLwVXy2TlxYsX7xnyastfBNLi1l7nde06TKiLHMaz9wbMi6aZJjC65k9CBkE+h1L98f9XJSaOIUXzdEBGfOJ5OYnHQ+bH4HLjoZVigsZOUwrQxxieO5+kcoCODqvDrZIF4P+hF4QeIQ7SGWUbb/zVqzQQx1lHuo0kWr9CywQflODqSOn/mxHi4gtq+ZYxmSjZwWIGgqIUSJNpSmLb2eU/XwQy+RzhGePmaWKsN5P052O7A+YUZLI4csgtqbGOcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7298!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003424312284"
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
  name              = "acctest-kce-230512003424312284"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
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
