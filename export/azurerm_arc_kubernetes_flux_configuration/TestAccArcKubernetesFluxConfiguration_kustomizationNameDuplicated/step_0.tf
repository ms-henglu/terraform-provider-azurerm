
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060254532888"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060254532888"
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
  name                = "acctestpip-240105060254532888"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060254532888"
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
  name                            = "acctestVM-240105060254532888"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4602!"
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
  name                         = "acctest-akcc-240105060254532888"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAys/+F0uF9rb1sUIlii+adLhj/hFLF1/dSCOQqIWaYv0xOhHOU0ENnYUgbS5+432YaN+V2ZwduPnqkEOTUKS60HKWV+Id/kAyUeh8I8BmuTMTcU9BGgqnpbC7zel08oCDuIMEdxE1lgQf32QQ1SWLQ8Dxtuo4RizYoRNAn6LPnkTgjpILQY6rD4L2jejJi8awdqODzYElFZsHy6GjSQD5hsT9o0aicp414KK9QUidPE+ZP/9jLRmSkIrUUMhMV0Ao+mDTKnNCFARaoTBUUXOENkBd83SKj+Sq6Im9BYjyUvnsIRahSNRsFRH0eMr2fxD4n6+v/4b/AOg112MPlJZwwmLKnc+reJF+ez9i38t3EwWNO4jPA/frTBa35I/I+O3hTVF3oOAoy4aWPwf2NlWwrLktEUFfEpuw+VedNR6no6+RX9YDa7NZ2SErU7SDvKMUmU6gG5P8n3eamgjjtO0+ZqXJ0xLaSMxeHAIKGMAKiEUCshyUKV35NMATAHjtAANutdXEhHMVLnurGPOF3qVGNLFhaX4Z3cowVeeJP6f0OgEAe1fiT1bB0Xy7AIwaHoNhd8zpdFYCv9AhI6CGtnyD1a1oWveVjsFbd2iMApUdThZtBfLnBwmu0pHvj1M49mmt4rXImApCWJ2EhxLMvBWjwDciim/pIre/vQSrWaM3GV8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4602!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060254532888"
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
  name           = "acctest-kce-240105060254532888"
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
  name       = "acctest-fc-240105060254532888"
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
