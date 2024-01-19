
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024516412693"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024516412693"
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
  name                = "acctestpip-240119024516412693"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024516412693"
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
  name                            = "acctestVM-240119024516412693"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4497!"
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
  name                         = "acctest-akcc-240119024516412693"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3MutlpxbrUee1PP3GwAon6OxizBnSuc95XVwde5oXpVdxWkUdzfLQroHYHCUzHdjlT7ZLbXEnacpf2oVM4AlYl9CHnK5hxcEcu2BQNyAOz0nJXWISvT8dwPh2akGoDgLJyKegXM/1Fq40aXErUMrNsWbu3OYVY3NJ9UfELHxahDlgwVLzkHt77+gKS12QwUjMAfmy9W40gUmb/Uv8RusqZyHwt4MEvQedKMYlVmhKb7KrLFuLUZUnBCQr+Dl55S3dd4h6artpAHcG5Imj7guF0SNB+hQN+M7tQ53ikKHsk2iH2C0U7TQVJp95z4xi/RCZYWzKuFRonuQNirJgfd5+oszrp2guq13e74UMRHV1+ci31VyVk7M3aCKOpSUPf8RppsiaSjqWgHTHtdbu9IToOE2y0Exy4mjGZ6Ho6XoiKOZysAVyVC0MOweEFpYoXrTkDaISXHfFCGBs6DyVluJokU4qD3di9znny7kdjo/WJefWoCgTi8VqPdFvWIFNHDFoQdCqx5qbBZN8zcXSSdUw3sphsshKxpM33zewMVQJb9tufGGfS0w09ObhA0L35TwcF+yjix3bDQRJiGROH2zMu4HooY2NFo5J3hipEMakAiG2qLYz4Pvik37FNXI6Ok1IE698i1ktyVkkuz1+KJTtFNoF8S0KZ7b8tS8sL/dMtECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4497!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024516412693"
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
  name           = "acctest-kce-240119024516412693"
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
  name                     = "sa240119024516412693"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119024516412693"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240119024516412693"
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
