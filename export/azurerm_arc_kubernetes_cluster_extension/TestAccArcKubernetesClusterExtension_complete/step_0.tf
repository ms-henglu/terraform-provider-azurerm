
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060230070347"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060230070347"
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
  name                = "acctestpip-240105060230070347"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060230070347"
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
  name                            = "acctestVM-240105060230070347"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2511!"
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
  name                         = "acctest-akcc-240105060230070347"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3Zi5VRszVJCSyTyckewGJz1SszaVEKSsSLPnNy1uQ8Z2vB04VgRfUUA0lw8FToO+o9B2bpYv0UUxyyGTBYBPyWCOJh3ktBimLr9VLwjf3sG9AikapdsYRCAIQmVpjF+ihBE+79JuUfL/aCjckTD6WCDsOy0xtF6vPl3QXq4EZJgF1INwyYceFIj+bT4MUHGVglxHpeEk1H+Q30hZbNkDRH6cc+nJl0vbdaApVhnqz3z4Kua428E4vZN/JRoTw/h6XqdGzNqfhV/m/Zus0H2zQA3tqPvwy8Ox0ZwqqL0yHrpaf/ld8FbtldvFI77zkii7c37Dn8J1v4+8cr2cT8dhPMZakxpvmVvLzfiTh5EYeinbJsrmHzUh89JYzCrFbVwaFsI79Ohzq81gvKjVAzZyFwb/frKv+ymzfehZ+T0996/Q5S0qrI1/HXfO9qt63ulO1wseW5hYw4/EvJq8awl2EsJvKEuPzeMEA/jxQz9/3NQomDYj4Dxqgy/9bmzc3BMQx/28U7zn8qfl6Q8uxishL5N+W0wPJ9TBhHOqLIGj/Do/EnjixqJ6wkf3i3/4AkjheRehz23DMyWlfwPl1KgnZptppvk1YTvbB1Xg02KOZPX03iWxqWOpmqIPJYGhA/GUVFtYtkly7D3fUvnJ/RnwJEI5TDnxp4NnrgQzDVPEHcUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2511!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060230070347"
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
  name              = "acctest-kce-240105060230070347"
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
