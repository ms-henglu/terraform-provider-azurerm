
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003340640686"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003340640686"
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
  name                = "acctestpip-230707003340640686"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003340640686"
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
  name                            = "acctestVM-230707003340640686"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7587!"
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
  name                         = "acctest-akcc-230707003340640686"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs/Wd+YA5viP6d1MUw/k7JImfBcAXo1xc2JnEznWqNLBKdkpegm+RTJPJSj6caQTN8/vVoeF7UX9H+QMwzGSJrdutN9kCTGpjeAiKYUeBo3nwFay5jt66phh+BtF49iO7FzbEru9cye9bb6ckCYAup0Fu+1iHaTuucZEq1+h8JmDiQBpBrVP/yonyXGWm7EzNso9v7tpTK3tIondEPqCM9IkEX60WzVgUjAjTLwc/3WFhfTVCpucsSsj67xRhf66lFxeec+1xCCpgLaR2H3ZWZ9c4HZQNst+aPYsvLgEuTmLxQY/PIJ/lmnHGbla7JGDB/Fk/CFXVjBTb/JccuEU5p3e+rP9VJhKfWEpTjSPBJ7zbr3JeVWS7JIOfYo53yzF40gs+lF/ywMknBrTuZkqCRHfQj9Cx1mk1pihCvSILyiWr5dg2giX97Mly41G86QUFm44GGNeNXKN4qHamAcqKwDdtwM4LjOUt9f9o5qWVVs0QkSyjkVRi0flwprG8N7U9eHulU2FbXOqBYPSZ7pa1gSHolYoCgqVOvw3GND2i/yzb/1qpZmtZwpmiaLuJgmreprSCKGOT7h01tBrnrNsRiPHsJSLEgVb7dPvmLrt/KPV+Ax8nanwAYLrqLSeJ64VAojtcMyyK++NghcmRULVXC5oA4RLYqg70q7aDDS4ApakCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7587!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003340640686"
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
  name           = "acctest-kce-230707003340640686"
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
  name       = "acctest-fc-230707003340640686"
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
