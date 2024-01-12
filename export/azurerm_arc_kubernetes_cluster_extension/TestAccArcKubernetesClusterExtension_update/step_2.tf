
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223931205087"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223931205087"
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
  name                = "acctestpip-240112223931205087"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223931205087"
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
  name                            = "acctestVM-240112223931205087"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1092!"
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
  name                         = "acctest-akcc-240112223931205087"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsNYETza4cZKhwwsFnoC28+LbUX4ATXdtF1ldEE4rz2HyKlnK0mMIdSMiGauNXCxM8BjPSXantNiFGBzzvt6p6EcXB/yltxjoKJNC2KFc9udGGN3CSpS5tB6SIgrirmE/wGlAHL0SmWE2NPKJa19QeovQQMwpVehcD2zfeX6XgFPCNpUzEIlU2TYFK/1apBBAZpgPRx2/NnYDIhRaBEuAqIaPbHp7JMogX8ykcrl3YjGItcpNpomgiIthtKXH5D5+RZziB52j72c1R/v5eUtMxiunAVWedpoubbn0k0KS8ga0CJemMpYyLyUj6huCTzw1lzQWyl2BFW7fiCbBoNcMqRNQcFbkm9gxB5pq7DAG4Tc8dwDEO3wCQ8Ko4kKvlsrUoxBPg+81yH/Sl9GioElZRhywHGUC8xu05DhNjMuNjgz4zw5T1ksUZEJd09ttbITn6LBx2rxd1rzXvACorKEEl6+WrBtGNZoBF5qpZSspNt+CGRp7FNq/kc45oSYT9e2BtfsILiKEwlsCZM79E8YJHPlyioBnguNbZ1Tt3ut3+EMB+jBniSiysIrpq+eWy7wNvJsZLP9LmPlF14Mtfdd3mDws0lNsAN3E633M+2Lsi9roSz+WPG9eUFuBVNCIW6eoeW8myw4NSTK9WX5CMbiloYUX5du7W/L8BzGtWKJeZp8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1092!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223931205087"
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
  name              = "acctest-kce-240112223931205087"
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
