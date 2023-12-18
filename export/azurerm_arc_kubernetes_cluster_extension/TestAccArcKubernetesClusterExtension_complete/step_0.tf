
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071220956327"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071220956327"
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
  name                = "acctestpip-231218071220956327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071220956327"
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
  name                            = "acctestVM-231218071220956327"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6047!"
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
  name                         = "acctest-akcc-231218071220956327"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzVgVghprB+qdjyvOpbykX3gf/saMWLlUnMSI/aJbbSlrvDg2q+9c4J0WetUVlKxQdGdY8p28aqDB1nFrz0KhVSfWmfrjJR/AHioJiHFtdbP5aYbkPm0ht2FcNSctF6tSWo9J4g6NdSJTV7+nBuMdmwaEF6T8Fzu3g9+7QBkY4VvdyKHmlRRmE53TBRcLqEhN/Xj1VJ2wOur/2XlJw3BpFODkvHIo3ntsa+IR3o0I1A+9/t2bqTMC5ZtSFXSoYWZMtFZ40jXLiO67nX8l9hc4jQ4iDvxRyr/fXI/DKEhPQeuQtdqFHk5Tpn9MmaIGHu0alqDyH0/6xivLg/3TsmRnVc7ltw0P5wQSbTLdxam90M9oa/YYr1wl+P7MGGCTF+U1yaNxgOguH545KB6hzHC7J2Z33iKRUW+XnbJ2XioQTnGCIaQbNQmGIdqGM936UUE7BXXfWZlg4XKh9fSEmOBtOIeeXhmwukf+hMa0CigyTXijbHRWeVjmJaieEecOvQLqi3I4slAncpfDcO8UQALGNhs3MdKvcteUjIE/iSQsIGam1a0AVsHuS8+IKd2ur/ShbYC0+yydZkNbbK24k9jElJm91jIpynGjaq6CQhDkfLhVE5RxTBkTIet9hlyQd9rrE4ZuD6pbM6FgsrlsWpESh/8avTmXExHbxIDBkFXsftUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6047!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071220956327"
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
  name              = "acctest-kce-231218071220956327"
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
