
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122256904118"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122256904118"
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
  name                = "acctestpip-240315122256904118"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122256904118"
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
  name                            = "acctestVM-240315122256904118"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7940!"
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
  name                         = "acctest-akcc-240315122256904118"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2mCBj1CTiH48cx6wrruYVRne3SxkSokPNrQVPWSnQbUbKwJFpFmkRUpi1bfOD9752L5CBijOCF23MOMGfIBmA2yT+MDDQ+y9vW2l/LBi7/JVlRzJVkTkMSqlnLnkFmiOxkiUwPiIKO8JvzLIPFMu4542dcIbT5/mlPV+lktvF5DusnKMdxUKvKNMV3YLdxlMpCeDgQC9TKqpJl8I4x14CFdvjdKlOzn0Q1Jn60Hjt0rnvZXXyoSdpdRX+NqDdCez8duRP120k88EnDGHg4+TomNm80ZrrFXQPfy032F9b132guZFcmjeR7SI1DBU04VoWmOo0+eLcHrWLq5Dy1A0eNpxJ3m4GsOz/ci0/UdfYUGKgeYzIWfVt+b1pYWX5oTipvBqj6ORSPuIncp49OL5QpfMeXnMVaTHmudRXlXGHIcNTZ7X0sM8N8JCYLAZ1VQMFl2uN7PkmEFYmrMBNrj6LPXG7IQ0b3TMM/odvK2IRMVRWQe+Q22dcDV+Qx0aLy020No1fYqPSohd6tD0+6TeSQVtqOEEEdbllr5hL2qOKRLYTq2kQKj7IO5oWf81RATIuMKB7LYyqIYwaiy8vGDBrYM17QsG73AT2dkJe3YtQ/3VYX0WdqoDm29q8+yofyiydqgaqJLlQVEH0rAmIUuTIRUDLB2aDbh2rA9mD1ywJLECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7940!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122256904118"
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
  name           = "acctest-kce-240315122256904118"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
