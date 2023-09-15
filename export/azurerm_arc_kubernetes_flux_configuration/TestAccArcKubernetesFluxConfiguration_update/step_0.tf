
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022912361623"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022912361623"
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
  name                = "acctestpip-230915022912361623"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022912361623"
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
  name                            = "acctestVM-230915022912361623"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7821!"
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
  name                         = "acctest-akcc-230915022912361623"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz8tpYyDTVviP3SjiK6rUmgdP1mNuTuPDSu3vEqUMIe/78F6UovffZvMW5HlqZzURMUw2sF/NurdZL4p5PeifzkM4VkGqrmHMO7niWJdz1Sr7YpAz8ZSwSLCDw2rzZeMKunCLNs5y/tF43xcPhgWzNSW1BxKa4swOcGF9HAwXKiXTEvXNnChBd1qmsE+P+5eOqqLc2buV1vKayeGl/bT2hYZfL5k+Z5/b0T+VNx/M3rueSGTQ0qDYzdCE/qTmfNpNq1PX4BXVEPXGnd1MhXLe0KwSuGoWdE83QkZmENghvQFvjTdR2P0T9rhdZF1gNYSHwuhK8iklAin/TG6hQ3DZoeI34alhb4/ttB7XaAAeoKMBXg9ZCaDIXxEW7fU8/VoJmPW5PqOgHZkrN+ggcCJMvpxfw6I/rQz9Ylc/QiI/F9aB182g4jbcYKXaS1zZtmgoXLw6kF2Bu5VxDAMX6EWoV9cp9A/xgTorR6ggTc9WkbrHwBL4kjVGtf9Aoc3Ei9JFXzdPlYnzx+y+RH8B1AU9yZGRkXlUnqh3rD2BlOFsO4pdz4nQrEtUxZz4R1ZVRScAQCBogd+5u4aOHS5jLyzoKflxH7XoEmOSd3shxUIEVFnNMzQF/vm7VS7RqRRoI9MCL77EtRmlfU6xJ/Op7g3WYV1warq7jVQtdhTrV3DGc4MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7821!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022912361623"
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
  name           = "acctest-kce-230915022912361623"
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
  name       = "acctest-fc-230915022912361623"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
