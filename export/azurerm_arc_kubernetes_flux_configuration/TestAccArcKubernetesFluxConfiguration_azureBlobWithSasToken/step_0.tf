
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071245154911"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071245154911"
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
  name                = "acctestpip-231218071245154911"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071245154911"
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
  name                            = "acctestVM-231218071245154911"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd102!"
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
  name                         = "acctest-akcc-231218071245154911"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvw+eBIkhnshAMkLlwqz8E6m3pEWxAzbtYbLg+CiGFBAWxCh3VUJiUQgzVqMVAam58+CpJhtt1cXR7b4pgNloo6yril6k/LpW097AvtgxbVGj3hRRd4hTMXK4xUi77CvJ4WCPFvbCPadjmtVqJN8Q9MMkvwS++9aO9Vltfs2cb/DIFl5uMIro+Mt2PMGkWlIdHXw7toGj0/24MbXNs3J3SrvFGEin9CaZhnTUF812Y3ZHFGcPeODX5HwqKqboxxoA+faW3/k0+/WT2dcwB7VuJb56AKm3rSE7ax7vNm1lwSZBrsymTJupudxwqdbF6ERNqiBHL0D8sIch27SFGE0y0YaUJeIUAsPOb3ps0LHNk65GyO9bQFjnv66YkIyOhzCApL8GD55SQbdXIiZ47o5tr+VmsrZR/l7aLuW0XGIk7grJGT8waLi/Ggf97tdfS3vM8dlCs3AYae3fDXnEwOGfoPyjcHQNVqZAtcKuNoWykaHN8XnGBP5zv/4cLn5hByZC3ycqY4HHjbgbKb/CnOIaY6GS9/VYrDQIs/ZwiI0N8a2x+/40+qyjs3OP7Ibp9KqkG149WVSxxpHbwVSuUUjusoOzCu4z3RZbO9aQo5KmGcvnFgoDuRgaYojSvlqV9w7+EozpnpxEjVQqyim54ZS0HVjwp7YcCsrHlf4K0Cp1og8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd102!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071245154911"
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
  name           = "acctest-kce-231218071245154911"
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
  name                     = "sa231218071245154911"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231218071245154911"
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

  start  = "2023-12-17T07:12:45Z"
  expiry = "2023-12-20T07:12:45Z"

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
  name       = "acctest-fc-231218071245154911"
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
