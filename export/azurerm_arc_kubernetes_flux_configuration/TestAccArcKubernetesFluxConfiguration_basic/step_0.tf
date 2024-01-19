
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021529434650"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021529434650"
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
  name                = "acctestpip-240119021529434650"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021529434650"
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
  name                            = "acctestVM-240119021529434650"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd565!"
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
  name                         = "acctest-akcc-240119021529434650"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyB/GsVlQpCxvWuhFEKSkRTOSrRH+oSk8Ho9dUeQKDeSvBZGAJAXh50MViAqNcBSd3hQ2z70lChm363bZiWuNmGaj3WTrD43gKqVDqwS0Az8hlQfkQ4nhq/5XLfBDO4dx5BwdzCh8C0AGRgI5gm/bwrn7MZ19xnVvZsZ0pNK3t4CHb8cgoxso1qO2wG6z72wrSvUodrdRW4a/7jzEHvBh/zR0PRjQW+EPtvuENwpSgFlJ4gTTf9zmTWUvjstfosWTMeT6vlCgn2yqYpO/gSHV4gxoQWwqaiezH+IHo2QVuIDPtmj6T5Zylx74mcC2ZG4zIodqFJpnMJGIDx6I759HmZhWaHJGK/xS9iwAllYbQ3b1lHMRJE9ZYyR3n0TrWFoiXNhSXEDCHjIwudvuJlU0YkKqgV24QF/8abHXJEQAvHD2wzQfxKkmc9yFLWtmwfqs72wHrFlklQd8rzJh6NoHuhU+LWjjdx2PZqWsZKo//o63t9Oyb2Pq3rTpYtgix9mBgSuLCJQI8YySrVwE3EwgafkRNjtL9kp5cw5j51Q3HuYmpYNDnydC9qkrcRJInJYlUyEBW5vf1wzeH3lb2mOVqG1g8NpnTAGQefi9xOmUHj5un7pP/35KLLsNjUq+Zp67E1TCSjGt3LwPAGetSgXC2tYwacBIf5+WG5D6wf1TNV8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd565!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021529434650"
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
  name           = "acctest-kce-240119021529434650"
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
  name       = "acctest-fc-240119021529434650"
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
