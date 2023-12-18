
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071239072347"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071239072347"
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
  name                = "acctestpip-231218071239072347"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071239072347"
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
  name                            = "acctestVM-231218071239072347"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4707!"
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
  name                         = "acctest-akcc-231218071239072347"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwrSogDWlzgy7jX/yL81mCH2B3yPBwxZbT2IBQv38GnAbP6NO2eKbSKO4FIIwoIZVY+FpddoNAEnWd81aeYM0XpbY+mSk0baDUPInPEotCX2SvjIJLOS6a7p3TlmZ2974Gjyrwfdr+leRcp7emXu+CdRT5q8B0SmPHrBfFLCJjM5N4yjgE9xAU8CBwfZov4LKJ/4Nmwa2E/hT20fu10IdqXmo7ICKkBERDULesV2XB+dDTYI6YHS5kYtYkS6WtmhT0oLY5TssRgIbzMXP2ZkJ+cO20fdCT1d3tVxWdx0xJs3jvSxoXLJtF71PWwZAvMpY5H9bzFTZlN9+No82iaT8EPAPj5LfefmRBckIttnvIPT9t1PdJpbDZtcnqU+sIFC9sHeW2/OHu8lre0ETMTIjH1d9pGtlk8oi7azAu55SirGYT5pEl3fwVfmGGpJhNorz7vVpfiJ9X2TVBjXtHcxeVcnR+NBCH6YWKbuyZnPif+Iq/eBCXwbl63DSN3Dk7lfWximjRQZnY56A6B/Pb80UQ8E0wdm03nkZDekzc7nah1keJHG/OZ0KYDoWnh1A/qW/FSUM9JknZbIDZOKMo23SYYQTGtAZPKABk7b8K3LJz5aDKXEnVAPUFdYwBuGKQJBww4z0tuglrypAyeQkRxWmVJipG5lNIeJv3RqF2vJUS8UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4707!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071239072347"
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
  name           = "acctest-kce-231218071239072347"
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
  name       = "acctest-fc-231218071239072347"
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
