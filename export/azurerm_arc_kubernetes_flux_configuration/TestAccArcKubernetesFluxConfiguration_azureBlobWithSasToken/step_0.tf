
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014519758536"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014519758536"
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
  name                = "acctestpip-230721014519758536"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014519758536"
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
  name                            = "acctestVM-230721014519758536"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd338!"
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
  name                         = "acctest-akcc-230721014519758536"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwOnF57kTDzcXe5KCT/99nmeR7pJOTkm8Jm/IamxCgJjBpYCIGDKj5O6+eq9uItjwrxWOKqSO5YAKR//eWGjlhuVSQdmt/2Q2TcRFqauC50Lw3VMNiyHTiK5JWuKgtuUla2jwT6YQt7etEST9V8LKt6g/tYnd44FbvQ+q+VNUY8kWPF+pRve+TcXvtUEppi0pq83aSlGZHvkcc28nDF+BjZlwouWR0kQOfYGwVdethprYB+gJGjCPrLJpWjapw3KVNQ2pnuVqLnnlBhxGM/yXV//5e4ozxvkbd5eLe7fe75unNikjPHPusR/3JFy67riiEytXplrvCghyB8jRCWcUGQFF5QXfnWcu4EwCOFPyCmB1RqSIUinvCPAOK+EOmZD1CfBiBtZr+Pqv8+eFBp7L5f1k6F2PU7PYVj59c5caZBhRLOVm2nWSvJmBOeDRE7Bf/x+CRSUop974Y52Yw0B8bzgmIdIVAjXlmJS3k2ARIlExcC2/Rr9IhwDyiU/J0zTbANRPbrIUVSOp936kVyxwg1/yUVy73vuH1rj621F4F5dCJQXpTClTDCNulQ+YWMXD5H62fiPV35sRPVlyri3v3nfWgHy0opZVDBnIGr0NFviOWk8UhewnWVqR+Wwn2rjcDKyH5Si1q8NgeC0hd8dlSG2UDh/9hrGpbK0aBPNMspkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd338!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014519758536"
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
  name           = "acctest-kce-230721014519758536"
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
  name                     = "sa230721014519758536"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721014519758536"
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

  start  = "2023-07-20T01:45:19Z"
  expiry = "2023-07-23T01:45:19Z"

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
  name       = "acctest-fc-230721014519758536"
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
