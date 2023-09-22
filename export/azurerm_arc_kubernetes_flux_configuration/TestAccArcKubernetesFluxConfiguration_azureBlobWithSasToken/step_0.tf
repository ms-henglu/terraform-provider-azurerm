
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060614574797"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060614574797"
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
  name                = "acctestpip-230922060614574797"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060614574797"
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
  name                            = "acctestVM-230922060614574797"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5188!"
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
  name                         = "acctest-akcc-230922060614574797"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA016UJoj/vYrEAuoNYUMICs9jYoYI3y6i+w04QrEiHFg3+S3jOtPE59D/lrunMAiPzoRDTsPHO2aeTcMZ1j+fnfD9ccOZ1X1/YlTXAJuYtxsvQei6aZJ2rYIY7nf7AOEZ5sWBtocwmV+19lCQnfAe44Wb/dlhlfgga9VMP36CBMIBiXxxdQTWYmwemgce8VQvWuECQuT4yxTYu7dbQDgOdjdEdtFjXwrtmgHnVvz7Vj9hY1G+CXFHofoYo8mu3KKyzVc/+p2Ws1TjmtE5K8ZRBpTom4iLv5jgGQLH2pUnhrEOEEpwHgghLZ7pC7qaF5o/Fxm8WjGPLiFMVF+gXfBQmFnjsISaoejpYcXJ8jejN/th+XQlrJCdhARB17qWSC2DWO3gQ0iZ3V3O/U72j8sIov8MzJFWODxeEmNRrGZBr+K8WmtJ8ySYAeQZkheEM4Z7gBP33fqem2qknOYbxSjh33HKuQSNt9V72PSdDftZ3re2tZkjgnFZYASCtiB8J3f0+8N8eUdwX0wE55YdU/qyFuKYhxEsMYOG34HIswwYa4jED+e3x3Qo/prh4CI+IULs79pIN7uXnptTEuxvJrhsV5jN7MDIdr7+SrAzOKozrGBBJNaL6nbawXHljGv7x+qIgPFbuun1yOj/alsRoFmcOu8gs75t9pSzAtTXQ4w7BfMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5188!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060614574797"
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
  name           = "acctest-kce-230922060614574797"
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
  name                     = "sa230922060614574797"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922060614574797"
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

  start  = "2023-09-21T06:06:14Z"
  expiry = "2023-09-24T06:06:14Z"

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
  name       = "acctest-fc-230922060614574797"
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
