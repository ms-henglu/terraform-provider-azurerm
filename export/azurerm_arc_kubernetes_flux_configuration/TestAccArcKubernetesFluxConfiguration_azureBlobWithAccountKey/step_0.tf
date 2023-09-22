
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060612286399"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060612286399"
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
  name                = "acctestpip-230922060612286399"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060612286399"
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
  name                            = "acctestVM-230922060612286399"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2955!"
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
  name                         = "acctest-akcc-230922060612286399"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlld/vqvd1PJb0jhxz80mNmaLKg7EYwxkk78sUHo/+mvEdnxIcanAAbAKBfxyjasUMHHMBfC6mWpaeP4k8pIi2T9nGmXikdu8u1zIJVzYWXBkcKRB8bUeupwvbsTSXyQm5Pj3/WlR8PaL6dJBSe8oFpWRkdWT3CimkX2fGrCzRY3b89FyPLCzaAu7MtUaVAHBT0kzbfCD6CEEjfJ/vIGv95EQEJvix/a636H8/YGTAW5T4dzON3wj0xQ6tgWc+KpgvCixJ4q87jmIOlvC1f5csHRMmVSWDdrtMOuqFxOYGufAqqKDGLQBZj4CNdkNK0VcCtgmMRJCeLt3ycrS+bEW1bkxgyB+GXpujOULJwhVRfNikm4gOhMIX7Rg0utqQAWDiOR0A4SGv6S4qnpkEhiU0OjSLi0d+Vf07z2ZtWxvLQHG7y9uamws3L2JexHPsDP0SMaGHKv6nHP6deBsNAuqrt3uBiyFFfiaD7UvwmEskMWvqpryy+b3uHoH+TSwIDf7bHvvbbmvmbfx5AY9kZ7bzgH7gL74tQ/ZUqOA/urhGnkmQfnLsG3tXni2RyjivFHs8Lgqm+uEQQyqPEAhFcpzDtQGGph3VEWeQ36a6lxZgY8jPh3WOmDCflZgEHi/LUOiOR8vxFnPtzF5COZH//M5DWoU6JDkSIr9SRM5rvzm/okCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2955!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060612286399"
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
  name           = "acctest-kce-230922060612286399"
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
  name                     = "sa230922060612286399"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922060612286399"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230922060612286399"
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
