
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074310206621"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074310206621"
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
  name                = "acctestpip-230616074310206621"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074310206621"
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
  name                            = "acctestVM-230616074310206621"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8765!"
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
  name                         = "acctest-akcc-230616074310206621"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqiv1eT31tLUUq0TdNDFXwwa2azg2YSC9J/snZAHRmfHZHxibC6dFOVkZynTPoZbqRhJ9dbvxlkeFrhsx8bfdYT9Hmt/u0gpPscOu9FA0C0Z+UtzRgmyCTv16yH0cIDidK4yD7o+vUFDwhQ5Y7O0yfqXOHEjoNqfGQCvMsb2LgzAcJHgOCxwl1rEHEU5rdyCjCWQ32ItHvNYgKfgbAly461RcO1RUzi0ZtXwNajQc28oeiNrgbjGBHkM+LU164/0nvPQAApvj5QxzTxbqIRZEmYH6Za0oYqjz1U+3bK47x0BS1+tnS0FmJxKmTFE+kVqmHeUMb9N2BqaWfT5Q+y3RJJTxKze2PNOMOIwIwH1cTKlh57Ue/HxFm+14uE4fwjx/rWhtDl3t8cEJm49fMtQ+jxxsXeWvz6GqV9awXjWxc00lpPaB8IgS3FCQgH4wjrAC0miThUd0tYBEtFK2yaUGWZaiI4Cbhuskl9HVL/KlT9oQT70iYK7lDjgY/eGqlBdfObF/PZnLTRGkS0JdiYxtf3s5pWLPtDoPentVzb8mU5eZmjJftLSYCI2C7+4GzQir7/0GL+DwMGSn1qyAzggzk5PHOhV3r7WVBp+XCPgRXCs4ne9u05Un6ir7LuZgaddYXhKra0T0tOINRXnRyDq2tC7D1uzIrM9ErEcaiugktEMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8765!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074310206621"
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
  name           = "acctest-kce-230616074310206621"
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
  name                     = "sa230616074310206621"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230616074310206621"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230616074310206621"
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
