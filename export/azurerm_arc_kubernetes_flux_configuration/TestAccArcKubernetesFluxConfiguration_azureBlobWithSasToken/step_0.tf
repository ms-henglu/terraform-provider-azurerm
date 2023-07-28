
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031811683381"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031811683381"
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
  name                = "acctestpip-230728031811683381"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031811683381"
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
  name                            = "acctestVM-230728031811683381"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd81!"
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
  name                         = "acctest-akcc-230728031811683381"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqGtzjt4tgXNTwz6SZuqkKB7dxxaYGB58TjI0CRYBW7/Tnh63TRJg4DvaGF7qXFHgsSoIKXYv925NPFzERxOviIO+mZHL+0zLI5bVb8o5sd9GE47nzeqoTLx/AwE4sTiTgKfN593WowP8Z7E8siECAEHwQRe/ENXV5dCBXK14FHZhsKy85/eCHU3O40lg6cz7llskXKLG9R3jD92hlwxHJQ54FRLwsSHJhMVoNB7/uXVjIgMSVU5O9M4QXEcCuEut8+AUObh4Ner9DLIdl8qWbqHr3OJvNAVt3sYvxr76c3Vh/8k4SZRXxNDe85w8+2UPRGVEFdYAywS+IYo2D6aWSvtrPpCVdncPp+RmGmiH8NHMn5oRkkcLErhxDqLpGdsN6VCRVP6D2esJLdNhd/aKAMbL8wEu7dJz551qwbdtDJhKoCh7TUauomQfDsKUCjhRSZngx4wrhFydktQWCV533OW9axjyemammfAZCDf5RFk4pcMunLZ1XsH5BFTmTQQYdoo4zCuFvFKZqRkiNZRWX8JAr6Y8vad9okoJ46RjvQT2pySzWnHrAIBFvWAVUKOz4seKq+Mjr7YFeH6/ZOuPFPemsiBR7XbGt2SgoWpsdtMKyCeHUOTJaTRa0mxO0pysGZSp57qmQIIr2X6fEf82+/74IlqeFi83XLSqUBYbR/kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd81!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031811683381"
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
  name           = "acctest-kce-230728031811683381"
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
  name                     = "sa230728031811683381"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728031811683381"
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

  start  = "2023-07-27T03:18:11Z"
  expiry = "2023-07-30T03:18:11Z"

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
  name       = "acctest-fc-230728031811683381"
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
