
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060604267442"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060604267442"
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
  name                = "acctestpip-230922060604267442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060604267442"
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
  name                            = "acctestVM-230922060604267442"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4780!"
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
  name                         = "acctest-akcc-230922060604267442"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyhzZS+9PP8bcArjIk7LpTUIsg0Sm7A0wXGAIoWc6dglh61PPS5mRWvNpBIdLiKHOI+2Qv3xZOa54U2VWj3gvxenhvr1OwY0V7FhKdIHU0Un5PjjX7nru9MSsx/NzaL2sk4GQF9+YL3PXXmrkv5hQWzxNKUspK3lbnVd5ciiTDpIlEXJtRBIK8Vk+PygqwF74Upc3NbdaT52csUYEMWrv++s2bT19YcRu/jkqkbwG+jGOwP1s7mG8W2jLcl68VnNa/zEoVbL8zIHr9q4HdWYWj3UaTFuGdjMoiIOYObgL/OY0btfrBz7aEmCeO6HTNNbA4CLyjWRCDuCdyUksKdXQVUSbwKlV1JiZdd6PpZIUloFjGoCImoAQ0a3ISeQQ+4m6PMuf8tJ5eMbikoZzmZ47Wj3VACaNAnulcAiy1GgGBf1MTrtFPzafCVHgkTSRmqtzDNsc6BGcLELZT/3vThgZRyMjcH+PKUIFXe2xEou8w5teht9DkJcJ1RLQ34L0o33PMkIOLZ9QEDLpq6DUPNuB1+CPIYL5HCX1pYSkiPdnEkegMxSqli92EE6aX7JgHqDIS9TG8uvQKLVAi0w6jt13DRuIawMTWJiFrdCIEFg+t5CHTpUYLs1+5pOoubvvEDfxl3QJ0ylDBr2q2lqxvOum0NYKhaY6Z3sdMq6XzgQ+IKsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4780!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060604267442"
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
  name           = "acctest-kce-230922060604267442"
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
  name       = "acctest-fc-230922060604267442"
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
