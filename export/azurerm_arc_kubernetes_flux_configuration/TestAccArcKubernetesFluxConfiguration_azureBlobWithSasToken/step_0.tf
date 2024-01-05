
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063315675073"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063315675073"
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
  name                = "acctestpip-240105063315675073"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063315675073"
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
  name                            = "acctestVM-240105063315675073"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2084!"
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
  name                         = "acctest-akcc-240105063315675073"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2DKtVlOoyjaeO8WXNMDp7JXfKhJq8BAag2sLU2y5o3POG3C1q5xEwK8/PdvBQU6NR/y0afInT50gr6c0ykREDL8a3ZHlx3jsjvCwpGChThrqS2jD8qC72AlXi6LHjn4HWw1bUYM3M3p5hI730tvWMXUu6dybT9R6AZwSzzMgvKg9bnEM/6mI+HqmT4lJRiK/TVtZNGiskmhihalDNRCLb+OjeU+TD134Oqr9iz407CC7W8YBwRN96a3r/2OVZ9D2oM54JQ6kHFi2uhkYtheP8GrkiDGnckGhP+TW8y9275L+ymIitgMu7SBI4lhkngmbPjaQ3tu4/SbjwHem66uYb3E/vERR72P1hsx+wb6kPJjBYwBSxTZa1U3SxG8JNhSEF+JUwYqS4J5RN1NbQBJI5K9ZJ4cGUgoh/9//qdA3auoYKXWnR/olZp3qEzD2N02cjmOR32ssZM/XGc8ODIbRkuU+lVzO9N+fnjisfkNpVVZ6si3YA49TF+Xyc+z3RPZf56OlZ1cMrUBeBlOuY9IEd5wjwXcJ6xfjTV1kx+bs0URtpPqIA/WJJH316rCGlQQx4kVSCcV+adurU9TbDAh6ypbdckBQfGmhDy3YutvOqxUjcRoHQhZKhr9bA9ZgT1A2JzMiCDw5za68Z4G/5CUGW8+dxBhOBT+0/meyUW/xoXMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2084!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063315675073"
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
  name           = "acctest-kce-240105063315675073"
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
  name                     = "sa240105063315675073"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240105063315675073"
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

  start  = "2024-01-04T06:33:15Z"
  expiry = "2024-01-07T06:33:15Z"

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
  name       = "acctest-fc-240105063315675073"
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
