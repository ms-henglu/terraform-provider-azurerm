
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024025634076"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024025634076"
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
  name                = "acctestpip-230825024025634076"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024025634076"
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
  name                            = "acctestVM-230825024025634076"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7791!"
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
  name                         = "acctest-akcc-230825024025634076"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuLh3xmlLQ9v7QVpSvzstAfk/bzTG2AcOISBUqvE5uOItFHg+Fvs/dNpYMVm0M7xKVLBL1h3YPGCDhFM7C9Yn/dGQYAPKL7hEeJt8h8s98G/XUHm1dDrpy0Lb037xtgKKkgRV03w9Y4J3SmzMo7aaAWWlzUyoEZNuRcj4AoOx8KTkwyQ77f2ATJQyB1regX4qL6HOVZAbGQ9spvuTvtbWjilUFERFOtt2Pn0Ws3dsdWSZO4Te4c2RanLLE9K3nYEHiEPJP8pulxA0ez7Khqa781PB8GV2bqVA45Ed7kyRgbJ9qgDr6VaFzEHwbopwLPLLKUCgHyHjrPnRa9DPcT9L6gp/jMEAKnien4rb/7X4BXLYA4GLOjpvomZ3zCA1PhXe6UIk1ldsMrYLU9oV0wz05bXeb+qUwONsxnYMt/ZH9EwqbG0d7751gD9vqOC1UtvevJhxOA0e+1/sZ/lpON62m2coL0+Tup5QX4SL1C9euyVE8+MUXcWj2MMEQasqddlb2aJt8zBD2jHSTFlvNHn4GW4DIyLG1kLaZy703qWZ+fC4+jpErJYuOqVkqznwpxmvmQfi8CF0x8Hw5U4UcNgmOYicj101XZqXFrPt/b0xYNpGtD0oXIMfbd9JhnU0oKyR+mmXFXr6yVG1qiBL5jw6h9FUTcpb+AjIh/+yHMpUG98CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7791!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024025634076"
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
  name              = "acctest-kce-230825024025634076"
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
