
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040600717800"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040600717800"
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
  name                = "acctestpip-231020040600717800"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040600717800"
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
  name                            = "acctestVM-231020040600717800"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3898!"
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
  name                         = "acctest-akcc-231020040600717800"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5PRjZnLcZIcSeGOii3UdCfhLircUj61ppTdQ6aU3SGhd0KBocMjn37ScEFoDZuH3i4rU+WN46YBT8k/4ojAg7VnIPR7XK/FEeKY4MhNw2LMj7dXZXPNwi81A4+LYXOH8lHWJj/Pz1X+LERUeGi/s2JpIKM4r2UDUnlyK2qm04z0wF9v/gqOewcKqoL31Ewoks13rgqGLxxiolNO5FsuFu1KJ6dfp2OUoaym76TlTdY8Frzx/zP7rV1lAvd7jCZjIJ3LTm6buPfaDOb9wPnpEZ6B43ui/+3NsPzKUlBYffR3xcupUeSHpOFS2vOQ7RZMLtQUd0LuxEWpdoaUCpXrsaihNOUaLbk8L/BP/8H25x3/ivyT/CMYhAs3RaKmo4VZiYSsk7Op1PYXm7j95YcG6CacYoKoCsSyVFs18RIIpkTCVyvZ5clda0erOOJdk7kPcRNme6WstU7gz/UzGbgZUptmkLaqJ6cjzh9nJfheY2B7Dbxp4xnvnb0Rm4fs16Lmb6PF0FBG+Tj1zuChMJZog3d1LoJI6Pf9fIh823XmYRz4UGvO15oY8hbO7p6/OIx6wffsRXRySf/JAPEoZdR5uY9VdyNqXlAIBsXAUpoeHuUjNL9jaGBzXLlDadgLU2p+P3nLh/1oXFK9khDiD4z4Kiqu6eSL5StcdOYBTqnwWq58CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3898!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040600717800"
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
  name           = "acctest-kce-231020040600717800"
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
  name                     = "sa231020040600717800"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231020040600717800"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231020040600717800"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
