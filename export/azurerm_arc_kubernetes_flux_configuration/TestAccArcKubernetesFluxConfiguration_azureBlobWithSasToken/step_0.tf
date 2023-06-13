
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071349766271"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071349766271"
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
  name                = "acctestpip-230613071349766271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071349766271"
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
  name                            = "acctestVM-230613071349766271"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3238!"
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
  name                         = "acctest-akcc-230613071349766271"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAua9UExUx5G19juK6aq6hFonduaTskgGTz90UyWMTGoDh4sLjm9HikJ/aMWHB/2UMWap2MNthXoOnIYVrxfoucBvdm9V4GcM4F8NPN6xNGyc7eudT4lf5zZawk2BFPTXlfe7CW/oqqBneOzZEMnm6eq2Hn7MYqvCtdW5J3kQw4u2GOiWZpDNx29qg1iaDCpAuHABVpJyKfydNNds6m72Vq3tpVa261rC+63Rv4458DSx9USwSWaweJ+Ls7kzHyF3l9smkFR7IksPpseRwkoYM/Ht28X0KMcbmGJOUyVe5jwztOB8iZky10VR4gmazjd57G2arN8d8AGinTjxtpSg3qlBcNkZnIx06vP9fm5b5F7CWYf69w8gsppqdssEByZ72aK3IAJe81EP8Y3ZnVSYfZ0ftM9/t7DBV3dVRUqhvRGQrVgQ55oc5rpqw0aGPC2AvsEJRRwJKqcEJOuFNxRQkOHzU07lj3jckHmzAYaEzy45io+5mupGVaF7vcbSLYt4ehqLoXWBUwXhdB6Z5UA25+8AOZN8w4UyFcdqLqnGATDdR+vasOYbXzcMBl1A7k8RrowJvKgzLa1tDFkRfZUyQI3xX0zfIzKp80ruC8nhHN30HfbE4ErzjGVIsg+4zZrJjs+LHUb3lytZ6/u8InVzJHQQl0yDd3SrAm9ecn+M6qykCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3238!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071349766271"
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
  name           = "acctest-kce-230613071349766271"
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
  name                     = "sa230613071349766271"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230613071349766271"
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

  start  = "2023-06-12T07:13:49Z"
  expiry = "2023-06-15T07:13:49Z"

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
  name       = "acctest-fc-230613071349766271"
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
