
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040553230630"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040553230630"
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
  name                = "acctestpip-231020040553230630"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040553230630"
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
  name                            = "acctestVM-231020040553230630"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9850!"
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
  name                         = "acctest-akcc-231020040553230630"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwOwgSfyFn3c3Ag0kFPv7W9ZCj1sKTqhGTgTLm9A+xotqm+Jed2Ni7Ir069MZQQgaJ9xwRqhqRHMfResC/fGTt2icumw73kFPqdRGooaz9lb87IjXwu4kkha9GWfCFIAcr5mDcQXf4VRdKjBqe+PdRbgMAKGJwYN3UXZNCqdmaZXQD/ftltV9DX+MbSmEk6TC0ENUGq2m3nA61kqiIdwXljIiQ5q2sOWA18bxHM2HDAepHezI9MKgo2fHHsYQk+2cokpbi92FJRsh1CeKUdcSe0FQjZz6tXSArWz13Xl5rq9Of8BjFjd6VCSeX9a3WAjo4XfaG5Puymjeg1UDUZUftM6xAiApM2b24fygA29Enoaq19DNlejr2WHN16BqAv+bm2FvdOuSwLkK44qoeiSfUFO0haZDvHppARBRuk+SoT+YyaUtYWYvSr1aCoAdKHRvN/FB52/8vLkzhgglUa3K3p1XBBGPenWhqt/fzN83+YN7vXKliMDKqGqgOdHVMOGmkhe7+xkvLWGuXCNlKeUkIvM1TD9q3Mk5Crgvv9vVn7pponqDE+C3uV+moZlOgJEOPh09uD6x+cY8kHwjOmwgyLOCOySceAa6yHrZqFJ5Y1qMRih7sEeIuFxn0zNHLgA2ec+VCCh6koV2FUN459y6pFol9qDSg/2VosVjC8dAGDMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9850!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040553230630"
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
  name           = "acctest-kce-231020040553230630"
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
  name                     = "sa231020040553230630"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231020040553230630"
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

  start  = "2023-10-19T04:05:53Z"
  expiry = "2023-10-22T04:05:53Z"

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
  name       = "acctest-fc-231020040553230630"
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
