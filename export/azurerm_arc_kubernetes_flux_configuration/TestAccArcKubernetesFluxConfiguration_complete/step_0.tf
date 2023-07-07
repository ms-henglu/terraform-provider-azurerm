
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003338505449"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003338505449"
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
  name                = "acctestpip-230707003338505449"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003338505449"
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
  name                            = "acctestVM-230707003338505449"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8761!"
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
  name                         = "acctest-akcc-230707003338505449"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsu23lA8CF23RyqQgeWEKVNhKVRMEeOO0QDSCt45mZoRIVCO4F0pM5haizbyMLok3Dtpw7JJH5107ogTH0hGxlRtxyYbWfIOis8pxSmFIIrbQRJMFRr5okzK8mGELguhlYcS9/D6nKgOg7ArNh0IyyOW5j1/r4wabqwWseQp6/5LS3Yp2/1GQ7At0QfYvfl26AWh5W5gWewQ0lsAIRoc065ofnjZA7nmyh+vXgqyKHIinHRRKBv5SQDOWBjRP5ktFhyj23o6xfoLvuGHmNDvdXXjsoEGzl0HWHQ73fyViIDCWPn73+mCvvPL7ZIckZSp+R9BRljl8HJBKRtSkEeO7jy/d5z8uoZ4TxFrkcKkrphI3RFWMUoKzld5OLj/uj8t/3I3F4yF8FtVnC+RBKi1CuUVrd6kGeumAvihyqXbKEPZol5AUPQ9iAg6m6Q625XpGUSuJf/Z+i3s4BnxGYPwn5G5vUypOffwK0knoCp+yIVXxilkMkBCt9LOCMPGfKQqkADEdP7GBnxagNqbOYd6Y2yrLFNcE/Xg4qPwyQQJHSivADTqIMNrvmbbIk1RLIi7sWh7h7aq3xtuXwkr6JUlGHlkbNCaJ/idfSroscPZEdKuf+SgX/sNyo+Smd/kgaCrwZUwgPrGshWdbulfYOpyB1Lgw+n/AYuFDCAAOQjEo5mcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8761!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003338505449"
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
  name           = "acctest-kce-230707003338505449"
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
  name       = "acctest-fc-230707003338505449"
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
