
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025426651517"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025426651517"
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
  name                = "acctestpip-230804025426651517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025426651517"
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
  name                            = "acctestVM-230804025426651517"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4163!"
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
  name                         = "acctest-akcc-230804025426651517"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5lVejTr0ZKHyTJS2rgmPt1rPP8OKPDreTSq6xwQippGzjJuzWq07BMLQchlSQpRPkBeCMTwh9M68zLk6Zzm/+yATvoFzDuvjTPh+6GXivC9kpVVlsPqepcIFWiCsk5fylxZxIPzAIUR20NfsF8CQ1TI4HGEJcqrftrsyNaPLzKlZpaNatBxW43T+7lKggmdSVeBnYS41BzeF070JbspTDO2j83adjZnbWS8ADZHqgp9+jT3KJG4BMQrISa71mfVTgsilJX5ktxFPyuD0MuCNp52JpeNbsFJMiyW7Sl7P7AjQL6m3KiuefcsuIj6VL059ozmjVqdQ3VnC5qoGxqvGWMkiOAXwumcBFXT7SjpN2IV0Od62+ctN5pjPuCXNrkin68KSAPXXrsErmxeHbJ/arJtMgD8zFuXm1V5H50ZbXGRjANy6wOL8M1dsprwuMPEbvGzPXrrrOxfKNDvKVoTzLYHt4hSfsrIcjP/dVv/A0ZGD0AzOJeCb0HjgbShieNMG5caAP5SFiom1N5YKT59HvRTPFJjWUn+YsifVvgR+1q0tfFmty5IIne58cdg1yBMu/81DDriZD59gR6yq7m08VtxFX77KykkPc7Iibr1wS+z4iWivlmWvf4FOqw7qW4CvoE60l4mUWPSrygY+V4WueCYPXVVVUOqi+IFzXgEYUusCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4163!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025426651517"
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
  name              = "acctest-kce-230804025426651517"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
