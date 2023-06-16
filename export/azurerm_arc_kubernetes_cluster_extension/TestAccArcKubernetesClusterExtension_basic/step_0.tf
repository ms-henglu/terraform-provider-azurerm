

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074242101641"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074242101641"
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
  name                = "acctestpip-230616074242101641"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074242101641"
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
  name                            = "acctestVM-230616074242101641"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1783!"
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
  name                         = "acctest-akcc-230616074242101641"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnBvoiHHcYdj9qgFUHskPfwqSrKFDw0HcrnVcXQSbggNfqLlyI72lt9TvjR4k13k7lWkRQxJY0K2809FM3oPsauStKyPEzun0dcVfYOFxQq9hTf+sASFosh/VUd9QJEumEgdAThqJAvn/LVD3Pj6kMQoou8ZueXBC844topI1OficxNLmfxhxWljVPZ6L4BAxbVyk8vdySyvaEMT3ymydQCCDxlrngpjdFbqRPkjVY9OkCo3g/oSbp1f2UNdTuJDSqyZFdSVetC5s2/hkPLa7lVqQV18gN9dJgR5lfete0t9aBevGgsiJm7FeoCYad/MM1SFPhB99NC6pviVznNpLNV3sddgMMjQMoi/nOC81JhZU1oKCr5DLxh2U7eWMSQW14FiedXEHeNBlx+RC163JYB4qRX9ECmoGN/TTXMGCQBgObzS1cob3YeyTv5W9zQcjTaI0ccUm7IF6ECfDtbrphMXkBz6DVKaFQCznPO87sKU+bsdEJl6L/CmsXkzULfSTCTpRSsugFLKNjAs6HUxrKSwxvxzDhCU674zDmLNvzKhIp/ef1rkHlIfuVJ4SjbgjA1s6GCc1+xQ1WnIVgt1UKzEUbGws6qpNhSIskDxGcF5Vm6zBlPXpUOpcVyTBoPqUX1zsQhBFn3WnEdfFrcXD46lwL2mRtNM1dd6kcr/bYIUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1783!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074242101641"
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
  name           = "acctest-kce-230616074242101641"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
