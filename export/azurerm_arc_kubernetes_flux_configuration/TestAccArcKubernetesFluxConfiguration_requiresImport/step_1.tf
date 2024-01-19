
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024504912343"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024504912343"
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
  name                = "acctestpip-240119024504912343"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024504912343"
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
  name                            = "acctestVM-240119024504912343"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1574!"
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
  name                         = "acctest-akcc-240119024504912343"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqBA/okCdGxaN4Qphk9biXydcI6SDowRGoYKVhb55540IKMB3KOZUsdZWFbqjsDOWS5MXqNjX6TVls0N01aGxw2+A+oCKtcaaxBQsD5KCHchsAm4hsCfBMlEozBGSHPguPOcMVL5kQQ9l+UIodYBA6G76kEyK9BldEXwkaJmnKQKzNW1cBU5qjB3V8yuaoJv0GsroLBbCiK7+hu3OBTOnTTfIFSJtySYUaELnoyTv6Z6pxwA1ibVfTNLeMdbn8asw3iTi2biwdzRx10ch82MdUPu0ljiY/eQvqV9LAngFuMc6Nsyustjy6AlV5oXXyXfWhfyEnEWkv6vyq8zhyBtvO2aDGpGKg5Td3bjE1HVXgshI6xZsr5aghg2ahLZjQwTbTtDdU6uAYwvDDGClGHtRdEFHxzxf/b8737kJf3UKKgslmOrJHTydB0RIx8Gbuuteq0L8uPhUG/nia5paPutMQuiPtVHumJRKDdfNhifs1f4FXseB/qvZF8kQErhFAmGcm4cZi5JFQJ9BMdgnD5GbyN9/dcj+S/+NDVIciFMtjGUVay90FGJhvzjh8qHU5wPCzmC8LWgffe8psS/OitdLEEGQrif7wMCLYTtSHXRnUz4hNOi1Cby8kM5o3lCMTSPre9E43L/JJFD4L60RmnO/ewdHP1s9gaZka99OXwmSaZsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1574!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024504912343"
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
  name           = "acctest-kce-240119024504912343"
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
  name       = "acctest-fc-240119024504912343"
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

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
