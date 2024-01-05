
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060252823127"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060252823127"
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
  name                = "acctestpip-240105060252823127"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060252823127"
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
  name                            = "acctestVM-240105060252823127"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8899!"
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
  name                         = "acctest-akcc-240105060252823127"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmUIiBlXPsXUVWN9UiUb78QrqQGOMWHvyBQ4VEhM14C/sbdXfn90A1XzRduowZxLrJ0Al4Hi9lg2P8UaInGcmiOVLPevT8ACrOrMHhbLwOa482Oh6gPurmPpMo9ZWqtuMXEm0GKekRlZY+QhjqeKLYtpV//mttAT+OPfygcl8s4zbHD8iSwaMquRttOoKtZc5BHLmVwZ/rkxeQLqALznl+6zRzfurWICFCfX0OA2VKhrLAs04nPM6+XalL9R6hGQOYK/vlmVnm0snCC8p+MIgTga+DrcbmohGMiM7rkBJb1bkGtDfRTCN6Ka5ImpuPe08DiKUFupK7adVmDIQ1dm/Ukz2u6s1hAS+RWVw3YjcLEEFvkpw2Sxg27ap713dlj888IkyRtzozpv5IXKwJA+Srpk56e19ufL9JKDUY7e+sa/+NGriHAxyrUb5hCE0JCcBMHJRJGl5fRkPK4Ma+59m90pGnwrS5LtLOKINLHbsbv7mCykEn1CgRId1TW/0W2WifqnBkbs+vhrD6qhkOQeLjcjf1Mz7yg7BecKSxZSHSjV2k44eR71//Dfg0DBYo7wkODI5sg53Qzk3MsrrAyIpL+3PDuoAoSM1W+uBlQvitghIDbPdv/Img8YJ+eXfzCofpNvINPGZRhITI5RjlQEuVb3X5SO6ffaJ5YtNygf5RaUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8899!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060252823127"
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
  name           = "acctest-kce-240105060252823127"
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
  name                     = "sa240105060252823127"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105060252823127"
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
  name       = "acctest-fc-240105060252823127"
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
