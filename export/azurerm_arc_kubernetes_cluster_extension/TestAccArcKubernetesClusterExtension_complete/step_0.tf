
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031739699194"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031739699194"
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
  name                = "acctestpip-230728031739699194"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031739699194"
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
  name                            = "acctestVM-230728031739699194"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9522!"
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
  name                         = "acctest-akcc-230728031739699194"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3Crc75hIEsCooSlOyzivmElhpFj9lhrX6JEO0DTbarq3KCcDbh4+ERXluEdvj9Evr647OgiTH3Kv0dkWzw8+vCjrZgGLXOP3FxW32puY9MnAfMMKt4m2tuqr05iVSxuPwXhCmRR1m+nboe1EDx7P5vzba+QtLstYtFCd6GWQq7Tx/4cMSdO8M5zjyXEIkqXTgkRYj233ntt5a3kDO/TzcAvS22BYC2isBw9XF8YPG+xkavRz/sACq04rBMOoend4WmoSLb2X/jz43hO6f/6gCjBZT8RQcaBg9ZiIpFg4s7pQVJ70mlWLOPEeAYhQfBGafdRe1W0k/2Rlkuw2qyQGz0ybVb43NL4ATEsvQEw8+yS9zN6E4Iomc8VqL69AtDDs0RvZw1UOPURVs7w45kbw3GJFhtUFFy55YBwEXDekrtB+LpvkGzg/42dyvGWdOkRzi1/gFiIZdf5jPNYmEyaMIWJ11457o689h5ivuJ4yPtSMfLJJrs79WghP9vVc1GtneK+5RDZ4/q3nmVLNn/ccqYCYHPllnNJm8QJzHIMwAkT5D01pyW4OtVIkXIsZFwum9Zf3MzawXy8kDi23Ba5K12FXORbMQpmmGND6UkWO4iCHAVgF/lH7tagkVdUoA0Yqspicpeyoj9D297rcMH+Sz9B7PZEJjn8TJy62ni9yGmcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9522!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031739699194"
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
  name              = "acctest-kce-230728031739699194"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
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
