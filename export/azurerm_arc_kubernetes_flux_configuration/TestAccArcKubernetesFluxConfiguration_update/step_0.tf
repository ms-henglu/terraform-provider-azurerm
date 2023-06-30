
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032703577640"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032703577640"
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
  name                = "acctestpip-230630032703577640"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032703577640"
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
  name                            = "acctestVM-230630032703577640"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6125!"
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
  name                         = "acctest-akcc-230630032703577640"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAy5p80+2BjR1xX1RbzWHxxuD0BuSiiE28em5HrQl//UhdMi/+MdsLDBLxGFkD7CGm8zCgdpFtE9chQXgnhieKGwelaQTwDa8J3s6jRxBKCQ1uCcXMc2HwhlpSPzBDervZXG8VWsRtHdu9Du4nYfXm0FgwNJQu+UjD2to5g0iSmW/4G8DNkCqs3Pr7uiUn/5KyMPiFF905sF1yP2c+dXCWqeNG4cOQvQMOUZ1Jiz2B+dO3FbzBQw2ut1Y3bncBtLslRG6+7W6r8+KZZFpeX+k78FIAFzMmaRqKuGLR8rlPf9DvPuT8X45zlZjGq7jxosul66/qvc13VqmDmw9cqnWMk1IAThiPQgiXaqGxepZK/pHIwTn23EA5pz7KE6if4Zj1pVIp/oPLi1fiZfdRrD5pMlpvDX/rL0xxb6o4REWRUBIh/wpfM4pPVuI4FsVej8s0sjRZDQsPwpFbsjsvKmgltIMmGaIYOjboVPNLSG/xsM0P086bdSmbqCGZzeig833DoDpzQ8EpH1F5wrwuaJMJVpSZ18LQQgDQC8RnyCx0n240YvsZKU6tnYqDLmwuBaKjSDLuu0Ouft9zwFb7hqOtns2E5bT4lGZahg/qoh9QGbyO9BVdKQm+cbQLEW6q/z2LsiRErblzdodAGIZ5JjkM3bQEnjo+ZEWZ8V5vb97buhsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6125!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032703577640"
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
  name           = "acctest-kce-230630032703577640"
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
  name       = "acctest-fc-230630032703577640"
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
