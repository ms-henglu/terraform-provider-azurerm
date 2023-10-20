
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040547056344"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040547056344"
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
  name                = "acctestpip-231020040547056344"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040547056344"
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
  name                            = "acctestVM-231020040547056344"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3387!"
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
  name                         = "acctest-akcc-231020040547056344"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqjlcC4eb9XqNvdRR3oHmb8h/SmdVsOz8aF8kd3nEP1ZLUHPFj6tAt1QQt7HT/mLmD5x2An3eDLFbIUchEqoXqW8S/8LXfVhQnbaz4T7mDBTN6Qxi95MJdCbwdAvSR23g70Jw9YIbGbkoDQnxiH/ZxCuraM/szBPYhvNm6jX0uiQdZNcj33DeHREOx3INuGurSFbA0uieOBXoTh3wsG+sdgHsEg4JximXLm/g1aEE4v7NlLNOChn8VS3fVg3q7UEFzggLtrBKge14PxRHTkXSEqcBZ2MOELh1u4hoBwonXB3p8FXalgyd2JFandQ1O860jmdBP291kY7c4xCXCq/i+2qVc9cpV72jA4EcwlwVOSNS9hHBXJ/3062pT7mt3V/62CruONcM79F97tHikjslxvWMsPq+AvcBg+6PL4G5Wy8k3i6PfPX9t9C7GTTIIUlhgBRQGtHIO9WT8+rUEdkbggUyMKdV234F1X3jC0+YjnJfF7JmF6K9Dn9Lz7gb8EGBXNR9YZbXj4M3t/xvoakSN7F6YFJhgxuhyH17sUZ84lrPv13kl1FUtPubnMSb01MTIKMxTM/lFh0Y1P24HVg4dwo/qQqGGebqj1OJazboJFmwM4eJpNkp8MzCXUIVu2MZF3hfnz6zcKPySd7AggWtNCzgImVt9fNuCwiKw/vz0vkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3387!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040547056344"
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
  name           = "acctest-kce-231020040547056344"
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
  name       = "acctest-fc-231020040547056344"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
