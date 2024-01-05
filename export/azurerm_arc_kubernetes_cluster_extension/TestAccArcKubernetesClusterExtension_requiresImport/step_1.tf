
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060228538758"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060228538758"
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
  name                = "acctestpip-240105060228538758"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060228538758"
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
  name                            = "acctestVM-240105060228538758"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8042!"
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
  name                         = "acctest-akcc-240105060228538758"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyGd4ptGtVxj+xr4pirae1Cq9aPVvy2LGj+LKAMyXZV+nlTrYAwznWSIzndpIzecF8HOB0/WVRmC7+3vNfGE5KaPITTZ/bLZqCQlRL5PoOERQ344/Pmct/F6sjie7FsXte1Xu7d2YrUgQd3OOaV1o+yAbdc020VN5eDuaQA8ocaH7TpZzivFH5vAFdS2Dtd04PAlZBY209EZ7qhY0DJ1OxEUCe2x527yNvdnWl/CX/QTcNVx24ZzaJ4O/znEYciwtk33IkEzZBjkAG7NPldAX5mKkJAtop1Fgg1CLVAY1OAAZ6Ur65C3ngSyVxW9Rix8DFSIp1YdXr6a3R4Df9yJpFu/zz4V/xEoEjLqwgAF+AEsqvnn7EwDtO3Z7p3eDOxPiT+hQlDT6gds0gkQt/y3ShlbeabCapNp6/NxA5g001RbXdn2uzR6gYyJMuEtRYpgpy3vjJICjF2BkdfOmcxIMoPcA6BjMbDHoijXLlnCz+dCsw1qbbpeSqKtPxH0GdnUQbtxyQ3x4/o8LD7y4jVayeWgX3q6TVZVLYBOJPS7nFm5fLKBmNDZu5boUIaxhVw/ZHI/2gUXQHtVFPX9MAzUKlf6zLx5thCjlSydut8lVFhpiWKbxYXKiMgUaMvIzAiPQlhJMo7Ui2inFB/CusBlVC4zuxm38YK8X76DSnCPfSx8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8042!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060228538758"
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
  name           = "acctest-kce-240105060228538758"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
