
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021544451221"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021544451221"
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
  name                = "acctestpip-240119021544451221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021544451221"
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
  name                            = "acctestVM-240119021544451221"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd777!"
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
  name                         = "acctest-akcc-240119021544451221"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0xrb7TB85bEAxo3cwMMHnGQaVh0wcoB8wcImtulExdjs+QO0sHerxhpH1jCoFAEjpc9yMn38OUNJcagbNwcPL+sc+bgbcy9LLXROr41OKMOLuVv1YYGIcIZBxXiTMXyqyn69xRQvwgamabVkMLPkbCPj+WBjPRc0+5FR0qo/ZHy/6tBh0mJwKwUKTdON+QSnw67faXOMpPPIvPTOLCJ6xU4Jr1qPdC2QddpR0+SgJx7cw63fJ0gwG1XxNveX8e4ojRkVdjMbkiv+ouSi4nDK9kQ8+qFoM02zuU2wfVmLsQ3KcZ5nxELpuvQ8OJnSzIA81CvgNXrEg1s2mKHa3ilCzeRYn9FodYXjvRbgnxl63FNtZL7IIcbRk8tAHURyH5kV6usIc+iQ1rlfaTwzzQceQQVmENml4CJLOCJAdIv2pZ4IoPJ/Qnf/l3Tx2Qld29Ktydqz6hlvToxJ1ksgD8IkKyzOcaj0sIp3AahKstvcLzHZZVmvwrEStR23apxzM/nVXj7fSTDXgL6nfOPW4PX9i8dDDPUX8WDdaqmvk8yBr2+cGDYdY7qLuswv4rf92SYSkCreYntpvL25SLDxuOZj3sNHhcW2p/bITcTafuSRL3/ulPPgoRGfUH4U0Lpfo2CKg3eGoAYyKIMefQIOVucIAGcr3LtXdtRe7LXZu7wI55sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd777!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021544451221"
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
  name           = "acctest-kce-240119021544451221"
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
  name                     = "sa240119021544451221"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119021544451221"
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

  start  = "2024-01-18T02:15:44Z"
  expiry = "2024-01-21T02:15:44Z"

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
  name       = "acctest-fc-240119021544451221"
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
