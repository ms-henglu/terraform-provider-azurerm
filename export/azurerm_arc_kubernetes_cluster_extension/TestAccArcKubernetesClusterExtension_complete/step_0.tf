
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003318175718"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003318175718"
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
  name                = "acctestpip-230707003318175718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003318175718"
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
  name                            = "acctestVM-230707003318175718"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9850!"
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
  name                         = "acctest-akcc-230707003318175718"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyKc4OWlsdvl320wv7lbb/sdrmkk44+RD7B+AyVVkXQriQ88Mz3YsTtIADS3/Stcnm8mhu59ne9NuwxxA9MPzgJwkFisF/CL8G1rT/ENfWZjDFeMnoeC25FCihSWIVtsy124t/zD0npVcfP11r4/TVTca3S2HOkiJ189MqA+bIBdX3iLGUXTw3pscduYKXX6nFimiRVOq3VqiA1ULUsQgx1jFJQbPx/Y7QVlrGL2F40HIuGlJCinYVuFwprRev6r+QbttO1T64UrxoHFW3A+PiMbvs7v3gO7qz6MoIZi8xZQSfkBSKtGSR64JK0P7OGF+vYLvoEnI/GOvuJzN+EKh1kx2Hhhtxdnx4Vi+ccgbgqlZnvRmU+PunUfWwEfccGcYIfrIJw3iDBSKANpqz+FBULHBeRJcJYjsC0yoVZo8uR7LiNoHCYftnJOB1FzlFLg+/lmIF6TvSRNYTgs00jB6HsgnYKfBO5+b/WU6sdSF5YO5Y5afUqK7aJEnObxPX7uF4RADGHcSzibPzU2qmgeAKaejHPaYPEnwU4Bp6kGzdKa72k0Ij3YMFSM9SYaNGItF620AfADdKsssh3CtCWq58wg9P/OrzeteC3SyNBrkojRo5o8vuDLGv1z4q67KtHxFymzYqrIp8jvyYdEd4xdu520hDi4xumbUNOgLKLUt89kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9850!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003318175718"
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
  name              = "acctest-kce-230707003318175718"
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
