
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023538501081"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023538501081"
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
  name                = "acctestpip-230818023538501081"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023538501081"
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
  name                            = "acctestVM-230818023538501081"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9139!"
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
  name                         = "acctest-akcc-230818023538501081"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvD6qy1qA2aXc9VVafWzu/VGIkEMmWXvpPmdr9eyeXzUAjZIRfvCYpzG1Fa1JCN7ejLOSmUDRU5Yw0KZ+a9Ypd2B6TNrUhqVNHstnZA4D7EOu3aV4llNCiGfM8wT5nA1nIZMvkD8s5jLlrXBTFD43dlFoI4OiL5yPZkx+v0dxJf7yjzGCNgFqqDY1qKDYHzKSRPg0dzHSWaWiHcE6Nx7fkM9867fR32Ae4gRfCIY5K8h10DVjp27vFAyiJ+Pcuv9ZWu8QGSF7zIayRoCQcR4fPMVknnxnZdqzGhCt82c7WQBoUDrGSpxOxKAOjbZK3cgZrJCKlrUS9QkFrw5kjqD4+tMnrr8GqfUs5bpIk1+nb83Nw3tqevyn9KHZKal8AuhtAA4Ke9xWynqzPOASRwKy0T5QuVTRZvRi7hg1ae+qM4pf2km5LzYr3KYcEHyeBmCqHNSCcEarKQwV7Pnuz8BLHYkfWEUWhzymvWcqFBp7XIJSY14b+LUNcYlWi/PeIiGuT9u018H+vAMxpHuGr/mM3bpW7IS7eJfwLaPlc1r+HaWnMTo3ilSpciCuW9dzTsuBFAQ8zr7Cy+jf1ODjOw0Kf6sjq23G69kCMKo/NnBmNz5+FLG6X5WSIZCBXZRDWNCLQ4it/cfvCAprp6gPr8v/nn56fz/YsMnfHg5xafZ/IJMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9139!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023538501081"
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
  name           = "acctest-kce-230818023538501081"
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
  name                     = "sa230818023538501081"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230818023538501081"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-08-17T02:35:38Z"
  expiry = "2023-08-20T02:35:38Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230818023538501081"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
