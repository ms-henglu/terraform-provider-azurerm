
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003343185627"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003343185627"
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
  name                = "acctestpip-230707003343185627"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003343185627"
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
  name                            = "acctestVM-230707003343185627"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7291!"
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
  name                         = "acctest-akcc-230707003343185627"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzndcLq/XjfEqJdSa2sQ8LC622SAJhe1cUHdNDY5Lm8/uRCnkS4EWumPoPn5ciCNXGGk8rtx8UxNt1vAjtgfx7gXemnFJrwBz9uQGt6M6hm8y0x5TgPh3qzBhop7RFT/Pqq50R8YtkxZZRfAOoft5pGFROaH3UvwOiOVJ4NENEmupXL3WAkWmq1tomFf5jPwORYrJbobmWqsLd0CCS3E3E2VcyxaFxdlVvE2Swo/3blyoj/oXDPQNdXsgSP4fB24GKPxTKbCVyL40VKypGVOAyjTGjScPgikRHgpJo1mv1a1rUTz7iLjgtffhlViLSZBwcCgV+VeIucI4v45RGDv1M4xX4Mmhq1vN3RMl+8CF9Oui9LOlj7F5SSlc7r5IB5ggpBxUE9m66P5Uqzz9W3JNE1j7nhFPjiqBbIAuKRqAX3DZRZavJ2LOFdvl2fjLAa4uNQ3l5tb6kMIRmGqq6bQTN+4dVmKCKZcIgS/z8m/gN4XDA3r6bMFJIEC6Y/09lsBIUGH4kXECKgAZck/bPxAno7MXW6DeQ8p60PFN7M0sGWNiZurPymibhgBgJPNx0aQxesTsToNu+IwMPqmeVwex1P1aZdl2m7/ta0obMC84uAUNzlDSNq+uApZT2l98XWQLaZRIja2qvdp0UU6QVAZ3Ke4i3DbjGzVMsW+xDBGaAZUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7291!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003343185627"
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
  name           = "acctest-kce-230707003343185627"
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
  name                     = "sa230707003343185627"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707003343185627"
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

  start  = "2023-07-06T00:33:43Z"
  expiry = "2023-07-09T00:33:43Z"

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
  name       = "acctest-fc-230707003343185627"
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
