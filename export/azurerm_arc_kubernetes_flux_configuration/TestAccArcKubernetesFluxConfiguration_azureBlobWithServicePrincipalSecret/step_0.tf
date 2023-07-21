
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011202631323"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011202631323"
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
  name                = "acctestpip-230721011202631323"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011202631323"
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
  name                            = "acctestVM-230721011202631323"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7516!"
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
  name                         = "acctest-akcc-230721011202631323"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAo35E/kmdODTsmiHg9XZ/gcTFedd5QpeMZ3MQsV2WtpxqIp7/Ei+7T+lDQqP4m1vRMIod1tIR9KJecjo2n0vLRe606vn/aZUkFS+e3wlGVkvoCXL7/XpUvwQOs2dQjPhSLwf+rmSApvsYMLFpUpmKNuiHW/5tYPbTGhZjmfPCj1TchSFQaFbPcyoeB4NSkozf1dn1qmdr87DOLWwPOmT6klsGIr1x7P040LNVkcX1+e/zVt78v12MvdOqJbezAK2+bQmyNSQMcAEa1NAQ454zcuh9LI6Vn3L5UeGjy/YW2VVYiZ+G0DvK7VyMdjZul2tVGI4Bd1nvmRnJKDXXGPo/U11lwx8EaIVpA7uNUcX+qqolILHWmd2Iab9kX+5zG9W+rSiVPvzE1glE0msO6LXaCxlTOy2mTpm6XET4iYtWGkrait5Utia2ONnxzUJiYrJXkKY72H0Qt04O5TyTQNrUsNYNKMWodcdtzCjvoL7VLAxLce5X6nfs1XyKru+VKlMxFwV648vaAJITlD3RaTmJYDHQngX8nBOMep7dwgkHxAxtfO3GyuLh8Lb4JFo404TYx36cc0H9u/mrrWbUpPU4s+W+8fV+4PeytsFq/Hw9EzhMrcLCjJ6NXFZQW3eua+spHY+rZsM1/Z8l4u66EZ+uO9s2EID/iUwJ1KT+iTvOj/kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7516!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011202631323"
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
  name           = "acctest-kce-230721011202631323"
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
  name                     = "sa230721011202631323"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721011202631323"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230721011202631323"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
