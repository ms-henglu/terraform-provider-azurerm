
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064406741610"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064406741610"
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
  name                = "acctestpip-230929064406741610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064406741610"
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
  name                            = "acctestVM-230929064406741610"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7953!"
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
  name                         = "acctest-akcc-230929064406741610"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtO/yKGnlUc4WplJoDauPMe1XWk35d+AKd3knVYi84tT1UF8C9Lxu00+bD+qnBI0LE6ipXjpR6C4om8pjjEhrRJCD3ilylu19MmfsXRMM5bgW8yfprENn9VP+JACx3r3Hs2Yfu1DnqqVnOBAPr+9q0nZ/8VRlKy/B6v3IGoLujuQsIJVWx4oz9RhWHVq6z10JOLHfVvLP98VbCRUwRJIRrw/26o3vEbbi6drUriHxSSUlXAPlOB9wuSSBdo/YBxoHmdFwobasQKo0H2H/NrZvuEKMZBNMko2qqu8CJjDSN75CqbfnVKeFsCogVOkwg1L0I0LZsKsFdumDrYCwQhO7wjIRyBTmbxtccbm9hREgGZNPHhFY4yz4yP8wUMqWqwl7JCfAeLOHMI/Jnt6kePTRviPeX1UDs9HfGnB6BHBSN/ndFQ++CUS+h4qTKxhphH4dG1eL35GCJrG5G5NYE1O8/dUdvHOANp+2Fb0vdyBk7UD0hAHZjzlnS4yGZHMYC7YOyPng03cNK+p09BzjcCz2X9xsCqdoAb9Y3HoIyhBKsYUzcTxIKM+3AiB1SLJX2EBGZv0oi+wynHjEZDZHWup76awt2LJK05wDEtgCoQ2JuCEO9RGdD4NCKhRVW5nPKeX6cWiD07wrYXJ6ifMvLuPlh6nzZZlGRKhXDXlWnQGO87cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7953!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064406741610"
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
  name           = "acctest-kce-230929064406741610"
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
  name                     = "sa230929064406741610"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230929064406741610"
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

  start  = "2023-09-28T06:44:06Z"
  expiry = "2023-10-01T06:44:06Z"

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
  name       = "acctest-fc-230929064406741610"
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
