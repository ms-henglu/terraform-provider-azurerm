
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023537015236"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023537015236"
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
  name                = "acctestpip-230818023537015236"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023537015236"
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
  name                            = "acctestVM-230818023537015236"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5229!"
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
  name                         = "acctest-akcc-230818023537015236"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0HFBeQVgId7Wp3T5+TYv+bNF6OpVA6UFxPatrq8rQ8jnXlot6IuJUEUCp3xEmO2NsXrWStdEx7amIYztegL3cy+S3KIyld9jFpccoYFdiIFlNugqIDkY31qOb4nvgEOL9fXWXSuBYw0lNzkbov4BS9TNcrD/5GqkLIf2NCI4HfWTuFaOffzJt6LIuKt04u8R+CxROHPrs4sm4qRB1e4X1mlSGe7rtlQQddGh1UwY1bJIkhblqezTcIZsJ/ALMpICBuFmMBKrtMnyTIP560XulyzSJUHxdt3QrT1aJi0VTGwyP9k1AIj/whOcHR8IaoMUFKQlLONMm5OmHvWBzbEUt4IAt3p1nn0PQ7PCNGap+DhkTehRIMk6X/jtXALbd/6DC6Sy7pvn1L7LHruXqb9KVBU7GDWyAteWudNotltcH+yEEsap467UQALE06jfkdBOx4rWvtEJKG9plUwl6qBEkIzIXYuuvSt6V/dz7tPwPSJCcJ4yQPH1vW7GbEg03JbxGE73wbuyKJct2cXE64iOfcQIUcfI8sbPask6yAMRmzEooGEHYSj7xjZWCPbinOfsFJIFnaehhZXacBgz1ZCA0H/R1HPB3X3INcSjQhFoHUCIn+dyLQO3j+5nUUsSEfO8WGKYfusOTflspSyoSJrb+SKSFUFwxYwzARal4FZMZ/8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5229!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023537015236"
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
  name           = "acctest-kce-230818023537015236"
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
  name                     = "sa230818023537015236"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230818023537015236"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230818023537015236"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
