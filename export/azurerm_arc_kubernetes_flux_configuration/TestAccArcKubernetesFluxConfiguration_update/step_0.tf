
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060246158704"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060246158704"
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
  name                = "acctestpip-240105060246158704"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060246158704"
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
  name                            = "acctestVM-240105060246158704"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1311!"
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
  name                         = "acctest-akcc-240105060246158704"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2MXsS6DhI7d3sW8eTe+ceGkAD37gsBQ0d/TuqU51cnBIPb7eWKdMVsogD05J8dyCZCodcPMB5y4C8/b7V3pA6oKRT0/P0/aCYcrizVYcrKWLP40lU5Kejs4ZNvbC34i0/Eyp13cavvOYIPrpz98dEMCYSMex7HZdINZ+p8JK6Npszj+HRYLFrsaPqcAYhgtoYzoo1lw2H73di26D35QWpCnXpxsGBhouaz3+6CRYf83rQ2FMixChcrscczKytKvxMrBCBaPsIibx8clh/bHlTCXFIem04BZA0wMZXK8WfnyMT1xg1U54Ul9hUV4Vqh8xmh40ObMTtUK3mafe/2YzYixz0ClfedxOXVt7BKouZnuaNr8Ce1rxvfCHsygDAulzuwwFApQPT4sI/DwDv71KAqBuDdSJgMnuRUIi4Kue78c6mf+y31ZiMAOHLctwpJFO3hthedvjBt+92HOKYRfd6mOPCKdFzbtVCZTsgfEeZHBKuQ+KHTDvObl+DrJjy5dVgbJ+DP+LZqSoysWBSvrTrBkBPPn6L+PPP5L1WPQSbU3dAn/CvUGo6A59H0i7sBlcI+qPAGItw88l/U9FCgx5udlfiR3NVSUbqGEA3t22ZPotz6jS5Son1TkmhWeDrpl8OHz4aVU9R4IM78Dwjj7vjVpnhg3AGm1sF9OUyExN42cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1311!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060246158704"
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
  name           = "acctest-kce-240105060246158704"
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
  name       = "acctest-fc-240105060246158704"
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
