
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071353402129"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071353402129"
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
  name                = "acctestpip-230613071353402129"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071353402129"
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
  name                            = "acctestVM-230613071353402129"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3999!"
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
  name                         = "acctest-akcc-230613071353402129"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv9dJJq6dKzO+SiTNcqndAX0DWM+ek44peVEYYiXWaRvviybzlqZBVNDbaocg5Os8MdM6jgeOljqXNLYwgtCN2Q86zx38diWQE2kpXXd2JtTGzpaEUqMdVTe2Yzk4uGT1wcJh0Xl0v5a/TJ71sC00W5pV/5r8C6VlCKCeQOFE7yimDeQYNR7jOpwsk5VFIro7eum0Imdp6f0ZkkQtDGcdnI6/HZC/LoTynid8ZrdIdoRZd/LBnRmbn/o5B30fGmETLR761xdfvLUteL8wQIKI8P0me0QCdXWMJHiMsp5YFdVRgQ1xLg8Kj2sI6D0P/EcVWVp3/LKwSaxrDRPYFcEy1/Kw8cNzMiSZ+aOtqdgKkJ37+X3/+y3eyGNQqgH/SSflokhW0aVfWStDP5bWmubxIT8XZmahhbg884ADrZ1BrvDNFszMU2nMf4jD5/+Bs5ea4OJsqrY9P+tgcFTUxZO30xZq/NEA5h8kgScq0ZUgRbOUEbcab1XIGY5LVdzgH1hNmfbcDdPguOSLrkIoCjrbJERZJIWcFu6qgPe0hrb/6rRm/vejA5X1fqDehgioEUO7oxz5zzPigj4mDC3wSY7rrTdAa+cwzFoZPTRF0sPAm590N/5Jb1BSrLPwMFRWqZKWUMuWNOJUexQkwuXAMNAv7WiBlchsxozwmm0yeOOW0n8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3999!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071353402129"
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
  name           = "acctest-kce-230613071353402129"
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
  name                     = "sa230613071353402129"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230613071353402129"
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
  name       = "acctest-fc-230613071353402129"
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
