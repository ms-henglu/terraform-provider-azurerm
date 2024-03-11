
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031353564192"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031353564192"
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
  name                = "acctestpip-240311031353564192"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031353564192"
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
  name                            = "acctestVM-240311031353564192"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4241!"
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
  name                         = "acctest-akcc-240311031353564192"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuEWpLTHEGtjiz6Gj+9ZYccoObFbBsZdokQqpvvcT8I4UhWNKoDvGZwoOFhX/vXfWUUM5/VjK3/sWgM7PEFSRg+n0nlNyR9GWgZeGb4Pupbdbq3BKkavhEBeew6bjwqBAEQ0LWzQV6R/HLCpL05YG3uVlG9YVhpOgZeWtAZ8T8Qgvk9BvosGesu2PoZOFSlQHEJkqflneN+3yOXEvx3zJnmqYMyp3GybvGFQbtgED6BDv68ccRB6Oriky6Ch0EOiYoXnlDysNiHKmb7EeyckQxsi3+Npjx/EMxE5Ezx7m7EJRsSv/q74dXaCppWWn7Kbfe90YNEwmiXdmjyqNIpuw/9K6r2vNxfKrdhvUxgC3nyLtpCt2eqWkXvRABeSSJlGBVahQn3oDTGL3N4WfvEvJ7GaM84q2rPkO7ri0n1+70Yr0L7lDbQTdroumur37CruIp7CG45zUSfOStnPY4tkHuaL4R5OotYlfspvRUXVgmBLPUmImG3eyjHTJL6Nk2E32XVizewrnxRek8a0va5qcDk+BV3BjA13lSLCDd6SH5SO1YZQuDlj1f9egLOJbgxLcVKxF3H0vHzKueRujVi5mzeviYt8tuhtDm1HPSvZ7sjleaj8NMN6GmyaPx66msPjwBIaL/ElTNAF19qqK6srz7vaVnSvYp7jSuNWsH74wO2kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4241!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031353564192"
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
  name           = "acctest-kce-240311031353564192"
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
  name                     = "sa240311031353564192"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240311031353564192"
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

  start  = "2024-03-10T03:13:53Z"
  expiry = "2024-03-13T03:13:53Z"

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
  name       = "acctest-fc-240311031353564192"
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
