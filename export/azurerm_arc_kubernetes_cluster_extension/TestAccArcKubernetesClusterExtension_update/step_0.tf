
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021517905523"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021517905523"
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
  name                = "acctestpip-240119021517905523"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021517905523"
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
  name                            = "acctestVM-240119021517905523"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2248!"
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
  name                         = "acctest-akcc-240119021517905523"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8X1FCxn0uR1Ef0ix+JxgdXuA6Ye69thFrf19FgJXmmsK0oPslas+z9YNWvkKqZXz6V/OO8aU6KwMt0swrgVUXrBeKiWGhHhYFjge1z2Mt+h3HoI1KIChljW1BUSpJ0o64otyd7/u3/663m++NaeQjqvhZqntn4VAEMc+4R6P3P0afc+Wp/5/EEM13rbgow92w2DgOWkT9KARg9F8Zg+6HQLKtCU6V2RSrm9X0/rafw0LX3BvoZ/ZTfSSsGMsSvunIKZSD+lmW0WBV+f7KvSWRVRlnOZEwUFWWyycl1k6BlhRkvBPjNa51FAHCcO6YjCI1XSZibOYTDbN3AkdCd8aRnYeRubRluh3AloFrbETaZOb113oTWYsDqVUx6ULud0RW8ntDw0djQCe+wcFcf7ZHHVj1uviknny7+ZEiezAItfDttn4G+OT2zpf12ZBWAaPx7Y/LPz15EFseVGI6WGDctWkDW19GG+UD/amDaqo8WEDidd/MSnfaiFxtN8rMvQL2qhghJDFKW+dWPFfuSvQ4+Sbkh96TxpCQxPdBECDc3qlEsodwpVfxmRA2/K0pcXh7/9JiFVKOUrLGfVwp4uesOlBk5SCcumoz4JtcIr9Px+Xu/aMwlE5hZnLmPlU0d3uiQtKbl99abPmn6iuxOIFJQZ4FiVYUd2apGLM3I0KtnECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2248!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021517905523"
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
  name              = "acctest-kce-240119021517905523"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
