
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053633392013"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053633392013"
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
  name                = "acctestpip-230922053633392013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053633392013"
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
  name                            = "acctestVM-230922053633392013"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1505!"
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
  name                         = "acctest-akcc-230922053633392013"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnRwLydZoaZKapQ6g93YTbDJrah2v29q39/n8Ah4W1kNPHDuWM92tmT8IoXMCm+kC3OV1UzGXlh/iIzIDz61MfCtAczUQAmwujhvgfmaK+m9aIo9FtB4UFMH9bFSddmF2RLM0nTX6tIbjP4JVF0kJxcrm4CZPJ4paVxUWaRXQIQ1f5Z6nLPDFTACyVuF6re3NbEIEX/+agK4M2NUFZ95YfoAksXAc9VodRy5NvbMApGDwqLD15rkhwAtZbZTS48S9LusSSU3YWYZpu0wq5goTfL83pxwrYG8rPfXWpeVlHG/NUiX7xDqL5xHOIgwJzTZWPohwivS7qqii0pqBbl1WW7MTz+QWMGMTL4gcjjqOItip0rFBzY9UBR6a+MLZ2ACNcgfM3PTA7Ew2CbBTv0rjoCB50VFSDW9Sm8TYYbnsB/UZvEr2qw1qt6C+++h4Ow67ey5ZwguJes38eVRc+ELOW9R59rfMS/7vVXxx1BP6nsUSJ1tit2E5OrtC28iGfHCSoMt67Ahp7wXVh+uB0Mnbh5DUt6K2KXjhUeUSX4sKTzy4C1lDKXN0cWstkKEuN8PxIjkF1iMYYySQuetYblgqy8OCEOyDZKkO4iCGKB87wXPtUQOKUQqGpaI5bNu7NWHlmORW40oTcPho20Kcr7RyvE7/GYUm1kSC0AtcHCyHfDECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1505!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053633392013"
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
  name           = "acctest-kce-230922053633392013"
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
  name                     = "sa230922053633392013"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922053633392013"
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

  start  = "2023-09-21T05:36:33Z"
  expiry = "2023-09-24T05:36:33Z"

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
  name       = "acctest-fc-230922053633392013"
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
