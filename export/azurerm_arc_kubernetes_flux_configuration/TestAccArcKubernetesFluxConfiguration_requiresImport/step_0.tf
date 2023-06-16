
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074300873232"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074300873232"
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
  name                = "acctestpip-230616074300873232"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074300873232"
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
  name                            = "acctestVM-230616074300873232"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd59!"
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
  name                         = "acctest-akcc-230616074300873232"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAusnhig6O897ulllEMr1gVsDYr50a1WrBDOhMOKzTYCtOhkEOWsQFvgEZE3EXvKLtrl2Faf7vGcAs9lP1qPhc8yaVP4kbODF+iRaA7NgNd+CkBkYwNS2rJg5RaTJA10pSjMH9iJcsrFSj1RfZjC1YuZ+j+velOJEzcSpuIEN5wcxhRLRyCtbgEJK0mAV5TwyzCLgYtKtVokgU8QWJPf0WkLsvfHjXmtOQIxKG9IGCkNLSRECTLuWWRuTcyWYRh22KFn9ICGTMUg+WaLplbd0oNneo/Kmj9D1Ocs+TP2uGp/CVDpzIKU/bt3biGeWvvtSUi+D0XDz0XpMEgjx+1mw5FsuP72YzqSBD1vILh4GZ9WOtxIG+8SJznClGDFTU8kEqqSm2kaAd/P6FBB+fsv43flrTsz8HnR2CFym5YAx9+bD/1KvspbEyDpt+aabrSH8wFctC2ZSIeqCRYEsoSsrLsGEuO93dq5B5Z9igZqvxGayan5/zrrwqErZVAQPwBX1RuZ1iylcO7i2kPOl1YJGCJBnpXkd4qVYYQ3iQxK09mbkHMmRhKkjoYrlG9qg7ZS0S9KaO58aILMHZb7wE+2PBLDBySdlB7sz2JIvZOBv1LQeSMEtzHvbjqd6XoA48+no/H4OAeYRsH8msCYCUE1FdqiEITPWMJHiIVk3q0zu9nPsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd59!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074300873232"
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
  name           = "acctest-kce-230616074300873232"
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
  name       = "acctest-fc-230616074300873232"
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
