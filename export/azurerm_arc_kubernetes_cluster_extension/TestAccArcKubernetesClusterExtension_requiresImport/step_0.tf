

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024024951181"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024024951181"
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
  name                = "acctestpip-230825024024951181"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024024951181"
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
  name                            = "acctestVM-230825024024951181"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6215!"
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
  name                         = "acctest-akcc-230825024024951181"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr235zwmj0TH1jxPTreQQHW51rowrull8gwUJQthsg+DjMKOr1Atpx3Ea1m3dqxKW/iNW7Ms7uz/ZbRJG8+yUbitUMXi1avi1cDPY/TkVR5bK/XtVCjfSCfP2yutL+GMOV3FaveHf8yW4keRGQDfeN/XlW/x7pYb7n1acHibQKEmRCzQOXuJe09s/JO1i/nMb0bKhnwIp1R0caCRKzUhQ9LDjNcxvKCjEo54Zw3TDTLO3IVR5oXkVK5qT6c84Fh8T/GQC2IUgAwQjtV+iQf3uNPjL/5KAT4FoukEmAQytK8bwiowVOUuKHUznEXwnCzT0itlCKx27bj/UFLeRB5tW/gujJ/sCEnSI0Yg+u/xfP29MWy04E3v/0oilf3IyylhV2OXh8t0AAAI/lWQW+p1aYIwbejrWFeLazTBxytQP5u1fHj+7JHN0dwnCL7p8JSwToKPWT+hNmqQ7Zk10gNdR0xC+mEVy2Pf0BmGn4irsMWhUBv7xicexpkXXU0/u+IiH2rmmut8TnS9Ffps9JKORP8wsrxCVgTQX8dgTAHEt8aalffJqA1dOgFtoBhPZYAA9ZaA5iAOtbJb4aepQs95Fw9q7R+xremTYijaV6D5Hgrmw2E3eNJD0Exy+wtVVM+ToLqfsluRrMrboew1yzBf30Ty3N876nvE8hWLX6CmFMHsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6215!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024024951181"
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
  name           = "acctest-kce-230825024024951181"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
