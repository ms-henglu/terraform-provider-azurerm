
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025450499688"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025450499688"
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
  name                = "acctestpip-230804025450499688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025450499688"
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
  name                            = "acctestVM-230804025450499688"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5244!"
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
  name                         = "acctest-akcc-230804025450499688"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvFO3X0L1ce6a9NRArCZLt7vm1gntfLxwEupVrpD7+dPTmj1Sq88CG/DRpSeILIfiySaPLpqLWf7cT1XHMjoCkH0Tz3wc63O1EU4Tl17+yR5ZZlbNOHpk6uk0s/I5qI4uAFhl6X8/77D6EgB8HXg14pv7YZfQoNdv7B8JS71RrMJQUcXwbtVuRZ8K+fK7eKovHqtscTfn/M9ASrkO2j0MI/NNvytTduAQ49EEiGMTTmsAXUB6UcyjtArvjfLBVSUy8Peg7WIbGWmCZKNQkmGGz46cKaD+MtdtcNpBTl3AZ7jWfyQUEXXxsAXzHcB5Bxltzqt4jqDhhbFDTrsTn67C3v+l4IOyYpe+JtxeCIHciCXwbgCPxi9OkcGKONA3XN27+pCixsSbD0Vo7FvDVrRKsrAd84DbB1QJeFQpBcbBBeUpXUH7y/WjOpfll7DM/iHYfn2qixLgClAAlWXhuxoRiSB3qfRTLtYxRUMabQGvTNj4MExPZvg5U30D1FyKxG1cIoXGNY4mmTN8dOKD99uzsdbenBnv3nO5VcwtGHIBcf9c6qzwF3VgaFHTiFOYHBvh4LnWxYJJ5M6Z6HhgsHsiZ6u0i2Eez2Y1t61g4YNNbySEg+bBGGMTWjdytz8yb8+DjuhqdS1YdmVTVR3Tgtt/FooFgjTkwV1CbgsDA8yLiCkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5244!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025450499688"
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
  name           = "acctest-kce-230804025450499688"
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
  name                     = "sa230804025450499688"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230804025450499688"
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
  name       = "acctest-fc-230804025450499688"
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
