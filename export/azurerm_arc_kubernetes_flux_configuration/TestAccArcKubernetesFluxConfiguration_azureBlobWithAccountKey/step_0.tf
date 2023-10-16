
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033404227336"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033404227336"
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
  name                = "acctestpip-231016033404227336"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033404227336"
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
  name                            = "acctestVM-231016033404227336"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3939!"
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
  name                         = "acctest-akcc-231016033404227336"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0gAkAm2L0EpaLv3V1oM7aG6nPIeJWxCFGI+21qvjpjItR7llvvfBxYcERe2cwij/pRS6GMWtTDlHDTS+2FSU+muWbpWFn75gWbziJdQ5E66iudAxLsQxD31eutEi5MP0C5ijQJ3GhRBz9jWNyM7j4iZWF8OyteNi4P7xKrdcTfRpj8cV6ZN34jRhMiZFhMfKW3/VUg334otirCj9NFuAZeV09uUoI8t6P0P5M+Ef0nusR1QCDzXPPv1ls+sifQTPBhdg2fg677bp0UfyBVgfjuMjCRtSgK0ueCAMmxBSLPlmmfxKM2H8BUkF35p9vEMr9lM5Yil580fJRcKluJWKM/A6wUVxnhd1hZ9kqBmsTBxzqxxv9q/QIUCQunYNDkYWYMOLxQhhgjfkOrCMdG2D/B0W6y1d2TKSEAQM3OU3aOTI9q1OQ5VkXx3BNc+qbQU9NqWw5oGFAwzbAhfWaAX8lBF376XCc/DW+MsZ0X9OYneY4+EB9qRC4kJEfmlo/6cVtbk3OJR+t2CviKw2Jv1toZAsBqC5NN202BsN3009DqJLICwDFlJDPVdqY4YDXlnA97iDQNcA3EsuGlWWMbcjnpd3RIoykLWQKvMSF84N7uX7T7LXZFZZ2ILPDTWCdl3n1jtPeIat/YSm5axC+NdVPUbrISgKWERxGnNFSkWv0GkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3939!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033404227336"
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
  name           = "acctest-kce-231016033404227336"
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
  name                     = "sa231016033404227336"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231016033404227336"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231016033404227336"
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
