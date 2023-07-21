

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014444189248"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014444189248"
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
  name                = "acctestpip-230721014444189248"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014444189248"
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
  name                            = "acctestVM-230721014444189248"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2191!"
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
  name                         = "acctest-akcc-230721014444189248"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv4QvHEnSiCiIAMtkdzQ+8pjPcVK4p6SlOkP4j7OvHJpLe8USqFcZaPVQ4+HM2hvhqWhmNO8cQd5boTgtNyez+d5UDinpmSuaXBLSf4sMy3PHpjGBF745YuznqsbJ9Dfhv22ZNBfV/6t4JXQ+AvM3Wmt7PYqnaPLueZ44DvISywOjClGK1NzVwhjwkdwQKae+nAxGBNL6PisdSfUjWSU1yTYWonh7pwsoWbzlEd2aJCyl9HoIbQLLm05wFWytDgyF5gCQOCyghs1r5rZ5D+iHcoHcu/ocNJG6lJkEVG3Oqc8mu2khTrAqdXOrPAFg1LRiMOdP6a0GS4sWHYnLv0ymyGX+/9uKB+pWfX3jbB47p6QrmVLabTbxI2e8xHHLsxgzo4XEfrJHss2zhTBwZOQmpu5XLFc/zokL4hspH2r7+it9AH2Y3Ses/7f7mzJzxVmRaKxN1oChgStUWQ4oog3UNKr/4DdzF4H6pu0GkMvO/1X49wthx7SCMMxZLpHBYDrquWfLfka08Snmstfu9pmM/nqUhWhMYXtZzKGNaKMkDPxGb+8C9vRAaASQ1fVFqNY6rZQ2WmYOvsU44tmg3srWJJSuVTJFGJeclBdvUfPNQ8IPwceRT26yhMDrXGNWd1+77iwTvP6chfhr5kTt4C5lKAmpNkZtuo2FfN2Nd9TF9NcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2191!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014444189248"
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
  name           = "acctest-kce-230721014444189248"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
