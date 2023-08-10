
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142930820941"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142930820941"
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
  name                = "acctestpip-230810142930820941"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142930820941"
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
  name                            = "acctestVM-230810142930820941"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2719!"
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
  name                         = "acctest-akcc-230810142930820941"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA22ZQPw/Yfdi/sRdmJCT99wOI49x7EicRFOxRMPp7spc9z4LobMYQ4gE435dXcpQBY5/MnzsoRzowEvJemVGNXK3Ti5BgZFttEId+derHPYevLU4VBAYwconzEtbg94s+ahGfDtKMy03RIxKAYVIV8YTRQpWdhO5N/69XP/XpbytD7bf3ZXF88j9Jp8uO6ifgeFJ4XXEh2H4yr29VakZmuvyISzG1KGdRdnu48wpuqGNYLFrygevWG9yrmWCCKo0vb0gmZUdARcSF3qhTA/H5OgcFiKo1f70TegDylVanjv5ipsEoG7gnunAYuo4P0zRZvL80ZOaJlVNlkG1FMTjaIuIlCNcchdlkU43eRKgW3zF71MVNrt39UXpHVrowYAXp2xtmSCTKBhwjqhsWtrIGwAFfCI2XUegrTu6RHFEHFBUjbI+350WpzyJaf005SM4p1oHwbBPGDynxXF0lMksnsFKDfnBMDX5Z6EByKbLUFdGZUQZ1OiMbnkHWhrlK7AU+yUuHpuZWAKKwO2R6urTqc6kcGAvKj4sGJBCK/tAyMeYijw3ZEgbDMJPBq3/zZ5XROzMOTBsZOU4s1h0QQSk0JJhQedQGTV2vRV6942P6xid3DaB9VIYOzKgYNe3A2muE/BFMJ8ojNj2uO5RMBzDD1d4jaDhRvaTwJMqpxViClS0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2719!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142930820941"
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
  name              = "acctest-kce-230810142930820941"
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
