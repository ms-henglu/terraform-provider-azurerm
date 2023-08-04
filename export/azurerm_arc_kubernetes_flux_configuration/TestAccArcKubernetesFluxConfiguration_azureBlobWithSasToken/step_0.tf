
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025449474676"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025449474676"
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
  name                = "acctestpip-230804025449474676"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025449474676"
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
  name                            = "acctestVM-230804025449474676"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd619!"
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
  name                         = "acctest-akcc-230804025449474676"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqb/g4hHTiGW9ypCRCfQaYyVBMg6m4w52pAuqbse2ZXoiDvOz3KoZnL0yn6JeNFrtHw/A/PXRYke/AsHt7sP5Gb2EDSXEQr3COPnFuq7UNRdizvOcrYrut9280y0YjroVZqNlmYA6uRbdGHHCYnDomBJLdqJbRXuxdosne3MOn9UBwOFuFuz3nD6Q9geAEJlFmKC5CN4cBM+70nc0XBwsgC0gtOFY64UGfUBdiBb+I5OifsSHsJ2j7wmLoWreOeacTpy8oY6BOgp8/gg7jCGI9CgHz/W07haD+lpP0YNzjwZVgAoTRMLNlet3roCeXSAYGavAKYn1CL4Qa7684Q75iQlTbG8tXmDwv7wQfomR7UvCUdm/idWsy8qVdk0bfZKK1uq8p4bkvZKDeJxz95vITsDXjEKWk15N6pkjhjnw2RulltolnPG3yuJvZUgpol923BTRCK/SbYSoPlYYK2esGkIvgC/pMgNtvfNslK+Q2YaPCy3C42JQA9keegTOGQ7GuEr09MK5Vok7c0ao5qFTuVPer1CBL99FeOCeV914zyLWhGqGrDR10ZlADjEUbZLSgmTIVg2stgjta4cMrEFy2T8YdlgWddczidH1E1lbXXf66x9ByZheu29qbR9TXVaI232weocflU/e1wb39sKI4HSsqhlIdz1U0g8BahDtcvMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd619!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025449474676"
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
  name           = "acctest-kce-230804025449474676"
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
  name                     = "sa230804025449474676"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230804025449474676"
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

  start  = "2023-08-03T02:54:49Z"
  expiry = "2023-08-06T02:54:49Z"

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
  name       = "acctest-fc-230804025449474676"
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
