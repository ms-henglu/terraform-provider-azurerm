
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074200044556"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074200044556"
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
  name                = "acctestpip-230519074200044556"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074200044556"
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
  name                            = "acctestVM-230519074200044556"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4314!"
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
  name                         = "acctest-akcc-230519074200044556"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwZ4NG5cmCmZR892ZSIM2RCpOP9lqnUbaSa3oIdEX+Q98D7L14pcUaB0igzXsinLI9YthF6X9Uz3KvPL7Iu7kGBA+psOCmYHkXWI7u0uDzvrwzLTp+GyWp2vGL3EuxAP6UtJbtYp0hVjeYqRykFTXpn378nLhHCIrswsHtiCyx9vhsj5hIhFF5AA/qgJf5SoxJfkGYki6cpruLbVAND+U/qFHtoEp9IdqxRi/mfNbQSOxKbhM4FhKeFtmlJ06yTGPRPF9pTOc+NQpxupdloD6i50Tr8figiU5uHq4W8h8w0jSXsuYE9EWciPZuAx6eoz+MI4DGr7TQiCuYsdgsNufDhUF0y8/36sHy/Vka9pM1EoVffIdvvBY0M25ZEUXGx8QccCYEEuPA/dxchrnX3Y1cTP0cSJFzDQwRqATMq07AaldQDpOO/QaTWwpFGARUMdMkHOJ8nyusvVsJ8a39nydnL5MvOmFxiS4hB2eV8UKrhpGdTvUmW8s2Au+SWYQo1cHBQNpB2Etsmw8N1oJjafPKljIxU1gkT9L3sAJc4lX1UQsIm0Uzbx0PADroV2j0UvzW/GgBZ+e8jNDb2M4t1gDV2GFoe1HN5KVBVXjHfjMg0xp9xx3J3beGA1zMjK+YxkKLCVieDmUZbFv8UaXUkENaizofMOew+XCgjf8T4pyhvUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4314!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074200044556"
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
  name              = "acctest-kce-230519074200044556"
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
