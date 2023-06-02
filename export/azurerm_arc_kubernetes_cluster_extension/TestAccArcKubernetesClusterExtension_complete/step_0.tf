
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030135864892"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030135864892"
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
  name                = "acctestpip-230602030135864892"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030135864892"
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
  name                            = "acctestVM-230602030135864892"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4585!"
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
  name                         = "acctest-akcc-230602030135864892"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAt87PamgiiTSs13ImzM1fD/JwmQN6zs5SZtNogmxGgiSb6tTO4eNgOaUFBU/DOo2MsQFo0OuwG6SBDazMVZC3iFNvP0ZE7NWdPL3xQAjeAU4VmFp/P9WUn1u0crdTl2K1GvqoDUbiZ8ONn8fh+KgZ2AyWi6s1PhuPSSsCSqWfsJS8xEpvchS0kQ/sWjwLn5Lu2j5ybefi6UcR6xblndb60jXSxMsY/e1Anjc2ebPE9sN+8Vd4Sz4iAnzmCo7vrSof5x30ACs7BrW9wEAEUUzwFHjNtW7Ah2WWG5XB7dzaCZ1rFXj4mBDy7/9+lpBUwpB9KTOCJDlBdqURMvuXq2BGd9uyRxTJKFi2SLwvQirVwvhz0uqBr1EWhrJt9q/9kREOGyO7bBB42VAcugPI3cGQU05n9tLRUfIobuSIi/XkfhzKUngj6IqTNYNNqJQ8PCS8/OJw9VrKQVeLkoSaSGpZAxx8R09Zl+KQz/DNbOtpvP0TgpKxiHa/rtmRnVcXeC8xOOGLWvK2W2oQBzKgxSjQOVTU9pSAmni0n8HVhM6Xlmh2m8y6QrElmdYojCYrE14LEtPUyntY3lxdEqjYbpP+Mv6VvwgasaGNZEUMofifc2eQ90hsj2/veeHLmIxyb9Bl3TaQ8U3xXDm4mSTa4losPFVJG50vJ6Caj9MtUND7B3kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4585!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030135864892"
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
  name              = "acctest-kce-230602030135864892"
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
