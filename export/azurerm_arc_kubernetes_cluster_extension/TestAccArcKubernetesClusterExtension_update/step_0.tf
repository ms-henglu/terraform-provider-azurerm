
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090828795785"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090828795785"
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
  name                = "acctestpip-230609090828795785"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090828795785"
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
  name                            = "acctestVM-230609090828795785"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5101!"
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
  name                         = "acctest-akcc-230609090828795785"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAusyuE4g3UtTTH+RgIZNyFoYn5QCl+JOfDWZcWdVo4brIqGOk7vFc3s2hMXCsaeX4iTSjDKdfRE4KRg0N48bXs+KlkeEi5UQWMqLPyMYgS8gkSShvuaMi0u5BNgi5SkI9vwrV/hUC5rYg70d6SYicEud7bMMa2yzV8TQMyeOZmI5daKIkjmBshYCEpLiTiaWBSDwrH9WCbEUB5bE8VJG9+jKeuagpzyIpeAPo7c3k/ZsQw22QNEoM33jszNqhabCn+KDzvGiKtBEkp3p4XMW1u9UJ9jPjIVeq15jmTlsD0DfcyJM3ZqcmHznXa6gMoqLQfJ1CKlK58Rdi/MbDXqC8z+hoeNOkII3JwOpfejB+DBgMkvxSox9phP3NO7nXbLg4DryvV9oHHvHp/bSy3v5vPe9sp0yKOajRb6t6gkidtvaCCvRq2Q09TTncAzgGMXrZozNj8qgs9MySs6kMUMQ928MKBgLuRxgFo4uLUo9t6W4uY6zQECcAOl59taRtPuhvlc4xpu7FRoB1QukjjadQGKPQX8okEkd/LyS9L8ryGV7Hq8/x6edOBUC1Y3AdIPz0vE38IOmh5Hsxz0tllBXqqyGKpLUm7FMqRIKDK49HsikEkS54fnLE+R8EN/H7UBDgPpKqL1RTSerchqML8yeoFyEQCigqnzwSHXVZpR1AXicCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5101!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090828795785"
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
  name              = "acctest-kce-230609090828795785"
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
