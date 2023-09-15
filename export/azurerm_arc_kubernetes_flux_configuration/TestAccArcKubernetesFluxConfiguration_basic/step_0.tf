
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022906332292"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022906332292"
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
  name                = "acctestpip-230915022906332292"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022906332292"
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
  name                            = "acctestVM-230915022906332292"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7761!"
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
  name                         = "acctest-akcc-230915022906332292"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuOtgSkWUBPM3k2bmxdqp0347aFCoRWVuM2HFhuiK7O/00nVwIPwKV+Fcm2y2GBV7KYSYeDe3TRg5tt90wQx2tHNaV126gcrKVLFsRuhy7LjEtfdbxJG++/EQTGkb71Pmnz9H3MrQPs7/01YopTP40kaej3tgAiFu0ifxbK2wxOlEu5xGQUgOT19z27SPAY8ZPI38eqFut76pm/gmpQ5k0tO0vL0LAi8bHM5u4sf+7Zzsz9t2zoU/E9pTAIxps6SOBmTkY4zJfq4/5L4aG+POWIWklP2gNAmwEqVVgNH2rsXmtUyu+3yHVDGDoicsFwtcIB37DID+2kuNESynx/gmckJnBNHEVT578hjjq4bIdxEstIRyPoywWVARH4WZv0yjq7A8Kf9BebEGnCIyidX0LF0NctKwXf5d1WmRil9lXc+J5nV/mGL/tjaaQlaC9HE9PCgdw7Dxdl5vgLt8WJ8wU4/YtBoBqGMif64DZVmIK+ZhitvNRhscsSMIcuaZSLlkhX/nAYMdj+I1ivpaOP/3UO95LIT19iUV+8KPq0KhTxutXBPXplkn0qgqYJ/a1g9p7MBjnb0xTWU6rAF8GDGNyBnh8+CSnntRrZ/Ep/zl3/dRlhsAIfzYrMVarfpd1yzBSpC+V37a1XxQBQ47Zv7sg6YmFe6KIYC/jcTI5ZKPkI8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7761!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022906332292"
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
  name           = "acctest-kce-230915022906332292"
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
  name       = "acctest-fc-230915022906332292"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
