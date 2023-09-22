
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053630763020"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053630763020"
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
  name                = "acctestpip-230922053630763020"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053630763020"
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
  name                            = "acctestVM-230922053630763020"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6638!"
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
  name                         = "acctest-akcc-230922053630763020"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0IzVy5Q/pZBa/2j+fhJmizwKWG9BmlqeG6OU8x0ZNIFT2s05VDy0TMPDHqkmHfIjqDMlGq4vMYD8dwFgr2TKrQU7yTtDxhfd1JRG6BSuup3R8N2IRo9RdCiJYmj2PByE4sQi69aEuWJPjtFssD7LISfHt1YgrcHdAoaMS7vkb/FbGgP8e5nL/22lgZTs6qsQDKfdysR19HaMUB/izEPaSr8TaOpb1vvXssNSN6GmcP/jj8aLVQC1NEDI06DRKHga+ugJfwoVVf8OS2nDFPnTeC56TOMICg/sCUP/L0l4Akph9Ow8b8c1+1cA5DdOgiHqWaCdQ0NPbICo6fsGlehdgDYraOys7toF1zeKBUAivfvjz/TWaDCwdtuyLF+em+2C22nA6ZMtGhNRnSvM3x9x1sv2eqsbVFRVZDbKLzSH+3UUUcgjKpax339aFpN2h+oUOPfEyQT56reBjh2pdpGwHSkoSCH+38bpcCprDYFMxcCm3WUJMxakxb8y/fIys1PjY2xwuxXMf5JnGtXgLoKqwkZcYxZZ4l+PORrdtPPulLSqoE0BxNRahSQPCUKQ6ysM9v99T9/bF52KT0ZCMhq0DSq7bx7ncnv9uoZ4hsPTxeb8uyCWf7nwd/sVc3tc+jxHC4WcJZHc7BtMQKA5AHGToXrNQ/TmorwonXtmcfL7SZUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6638!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053630763020"
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
  name           = "acctest-kce-230922053630763020"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230922053630763020"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922053630763020"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230922053630763020"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
