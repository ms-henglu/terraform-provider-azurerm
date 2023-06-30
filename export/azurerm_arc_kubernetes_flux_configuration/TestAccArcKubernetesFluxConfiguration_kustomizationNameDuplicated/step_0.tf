
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032708305169"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032708305169"
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
  name                = "acctestpip-230630032708305169"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032708305169"
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
  name                            = "acctestVM-230630032708305169"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5149!"
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
  name                         = "acctest-akcc-230630032708305169"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwr6zCd65f7Dx/mJyiVMFZLdpnHCrMIl3EzEb3foC32w6RNd8WgYQt572OJ5R9N9bQ+J37Ch6dj0cELZuwaORjxVCtau/6Yip7RuNlyS5yS61k8cLAe5gxqxOwN0n+2kUI7/nDl5XSnm918XzFtoKZWqYzUtJSzCZVyxoUHNMiT+frIGgwA0k+byqr67nT2ZWQ3pfNBws3EzIdEyoQw/YHz0jjpIQscAc6mxkR3vdjph3tUkPWk+Vc/CF8xMo8e8/Bu6WY9wcJVvd1Rm+7J4P4skS4ctzMzJ0KNn29ZjJE62XrRt04I1LnXSQn5qY7pRxQSKkGck88SkVCoTtPH4wMHjxPBvLBUY0FrEGXMw0hft5WV8Ck5w2OwCHccDuJQnPLXRQJrtCL1hyDZksXpmyTO5xo4Rl+nJZIMVViy1QkXIRrMpH+czFQ2leldcNVcUvaLepJ7t90dSmLVrXYDuotGf8WTMj7KbpYuuFAsFuXSIV3HUeNtYZtcjDkrwqmOgUXimgNmw9M+ENQC72h4plxMAKurK3JQpg5rrupjj4hAD6gMuua0pmCMPlTg/GxpO+ApPI4P+6q83hMZUGwEXJwbwu7NKSBCOXJF/ubv/laaoRSKmZhGhSVgRShwep/BY7GvTGDGJqp5lOH1wp6OFox83030ZXmfMyRSbBuJKZiMECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5149!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032708305169"
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
  name           = "acctest-kce-230630032708305169"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230630032708305169"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
