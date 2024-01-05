
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063302868918"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063302868918"
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
  name                = "acctestpip-240105063302868918"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063302868918"
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
  name                            = "acctestVM-240105063302868918"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5821!"
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
  name                         = "acctest-akcc-240105063302868918"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwHZYf8YwpM2ZrpoCA4FzdsplGS8bY9bOMWjMnSDSON70tOO97FCVOmI++TJrVqrjO5vCqe92mHVKQculNLsEjZyNMSD+maPabFBHM1SIHxHxfptG04yu+vHlbTmm9AGqDFUGuoG2Wej+npinLQszgBjE5o346g2gORaSK5/eJlGp0biwZEitmcsUU1SvNMZlYm+Bi7sA8pBb4+v7Hgtynwh+t2noN42R+YMpk99LM9tWJ8nHUvNPDVR/RDVtlSLH5WrsbK85APKlzly/3wyVSAyYb5r9F2fAy1ZGkXM9s7G3MGbo7GlkcquAbtCYuRVLBg1bYB0ZQLTDshbc+6OjrAVyWIb7NjSYAZx8Ed3xttQYgg3tY/s5vRVq/oTLsfJ8MUllQl/zByXxxmAvQVOOyNhOuefiNfx2Y/EvM45GwbPhQ0o38IfENrRfPreZAmNEj0A6aGJ08GfwpqMeOkwy9HGjSS/QiVUHxggAR3F9DHd/dLy8V2llsQqC5OdgpkroMu5llXIkBhVHk3SfpovDTjSJ67C3zZUlaj4txWdJukObkyU6rILsq4RBDkL7UY0tj/K/CLAMU0IAvCgBk8DduFpzXSXsM5+Ogto2fa6dg+x2GxLWOBSXYaGKfEzsz2Fg049I5McePsh8Ki5ua9ahd6t7xQQtMHJS16bfrqE5QM8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5821!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063302868918"
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
  name           = "acctest-kce-240105063302868918"
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
  name       = "acctest-fc-240105063302868918"
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
