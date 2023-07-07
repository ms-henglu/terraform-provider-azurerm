
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003341868778"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003341868778"
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
  name                = "acctestpip-230707003341868778"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003341868778"
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
  name                            = "acctestVM-230707003341868778"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9818!"
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
  name                         = "acctest-akcc-230707003341868778"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyCW4sI+R9bozLGWZajJrJJO9AgS9U7ww38wDWCUoxk8PlVJczE0q8vSkVLM+fm381qQL7vCfx46UFUhkp3zfhwKLPq/VXneA60ttGMZ6M/Y2tlifA3wbm3kUE5wZft00KrghPqZPlksrKi1/G8VpxBy8jEzsRmYp2CeeyMeX3aOjsZanH5ePF22mAsuW63RsmoV7DBCdeo27hNu8Wjxicsch+yUgzLTy0yiFYr7tYP6w8rL1gnAR6oPA8nCB9pcydw7YzU2b5Xp5jai0UEzoHGJQ02JFSYuDiZ4zoHYNDGT58JVqj9/KLkq8BUhRw9of+NMlENR9IVg1kLL/yhdqVqd8AJFkUixQ2qpEILnMRXV4h3pG0Vx3yB1qM17S7DCLI9uWEft5Q701WFAijtJO9Ks993o2BHquyKdQVrUd2biSEPfUwLG0NJ4N0U6LEe+J49mz8sWlf8q16KRtn3gbj1EdmwduASaqF3A0WEwwuYr9u3iy7uFgc6UvOn8MDnBqFPxN8oKj/90iyPwIwEMqKornZlNUh03g4cwzQ71pNa6EOnbilLU11VpHLeMuuSyiGYViPaeaQYjrpvusBGCPT7691qu3tae9/gtd/y6GIi8Is2PpuBAtUl859aTe0a5DIwM5w0A9vWTIWOqErZhHRL2fIl/XGld+UH+//3pRuiECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9818!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003341868778"
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
  name           = "acctest-kce-230707003341868778"
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
  name                     = "sa230707003341868778"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707003341868778"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230707003341868778"
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
