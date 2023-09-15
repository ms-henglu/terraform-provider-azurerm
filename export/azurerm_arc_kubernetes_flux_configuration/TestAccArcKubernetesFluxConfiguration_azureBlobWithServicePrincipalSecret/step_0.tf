
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022918632651"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022918632651"
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
  name                = "acctestpip-230915022918632651"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022918632651"
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
  name                            = "acctestVM-230915022918632651"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1704!"
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
  name                         = "acctest-akcc-230915022918632651"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAn9OaePmu67XDmIqH03ASWr4sL/fQ5vZZylBgNehbpyAMBx/PIiq1uWlVebnxh0ZJAhigcKnma/OauB/DUGXuw8NoaMdvdl5BEKrovQ/iMQwagnJuN54/MRignJhRoW/RkQ8i8BZS2aRI+xw3xKko1RFC0510+ObBSSeX/msZGHYsgucB/kcqOTtHp8C4JL9NFP18szmSVauW36ud/N4pix+iAzo11ycLFgP+jT6e80hSzmXbUKn0Kf8uls6IhFvwH2us3MttnqI0L4f4CPoU0TNNnfWUfglL16tqk7hyJpzUJ0eR4KMJLvT+wjA6rWr3zkjmUS4zVg1LDAxgVEDE/9Io/SoDTO/V9rsiEv2l8D10XdOhok5lx6tYfzM63SrO99S8a0rIE2F1H9bk1OnZFOxVCmDg3xNVs665ThCXv8bcyVst6etczyAgz+7cyjLQ7QkK93lSqsKjvAX7ME6IOfJowqQ3IOxrlcUeJnksw2Ws/qsr2cu0dDIB4J5sXkEdVhqO4VLmw5K313e6qK+azE375AOKhLT69pFpkIquNCYHsUKxUvpfskym/EULeZhtMidJpxk/l8g3kRvBIyAyXqCDih6Blj0a66qqyrgkKo/7udrqV2Grsd1AcFNZmjzm7V4itISfS1bQCZP2fItppGvgIR+iLqYvQnIp1tvwyq0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1704!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022918632651"
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
  name           = "acctest-kce-230915022918632651"
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
  name                     = "sa230915022918632651"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230915022918632651"
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
  name       = "acctest-fc-230915022918632651"
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
