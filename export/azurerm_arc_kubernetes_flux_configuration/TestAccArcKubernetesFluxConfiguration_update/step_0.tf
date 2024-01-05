
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063308600549"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063308600549"
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
  name                = "acctestpip-240105063308600549"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063308600549"
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
  name                            = "acctestVM-240105063308600549"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9053!"
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
  name                         = "acctest-akcc-240105063308600549"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvw5bFKxmg1XAFERTAuJQ10Bz8ytwPrG8q5dMX+HF6154nxHbNebIFk5OdkJsGgCfD4oRPQs8ZzJ9AcDmOh/XrX+gzUMQr92c6ZhohfgxGpobpcyaIScp903GO6pASPHteyMI+MbgfWc9qs9k4Mp7H/fifD1ruRTERNgPC2HKJIFO3eC8VGw67EHiuR8d8foq+shBBG8WOBBNFqxTicwoZYepsShaSeKcfM5OT9CFfEjp0bHl0AGLOP7YMjNYEpavksOCsAw8UC98ksI/MYD7tetZzr03eGyoewJUDTNV0uUIFRfDV+yUnlI1TjEeDdzCYmNqVz4FmIwJbA+Z8UmWn6CXHrg8ZWyNDz/JLP2VuBLpM9/0QcSBfYEHTmvgoW8gtfUFZ9+py8EHkYnEykpAJtO/Hj5SQO0lVKFWEzMrok/sutZsUfR1D8TmzUGxIJF7W7U5J7gre44feabECkmeYOsNavsL1Ratm1eAZz8uwToDxEYE8+9Ain4LiTa7t0oOzBnd41yqSgMELF14tMLk/ykx9ONt2hC15Ym+yepahdBxuhKlcRutz3pmF7mof5zzSTbIq5wi8k7rADgIr/0FAUGsMCjSi4+jcNnIN45ZyTCPXViOdGQYpGdPFAgPWOqNqQGncRzBcn6YsGYHTO+gKNJe5zZ6Rm2RnAisiEQ+ocMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9053!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063308600549"
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
  name           = "acctest-kce-240105063308600549"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240105063308600549"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
