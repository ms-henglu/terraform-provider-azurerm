
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142946157923"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142946157923"
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
  name                = "acctestpip-230810142946157923"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142946157923"
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
  name                            = "acctestVM-230810142946157923"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7993!"
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
  name                         = "acctest-akcc-230810142946157923"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsEGv4G7VQwNxRdGJeE5YKttoj224STDB/5fS8l/qHIhUhhBGEpiZsP53lDrb0TQb43PsYjLuWB3cKUXCxbXl99Ry8nS2BDtKFgZfrOJTIqMoiWiZC6YiD2NUC9IHtF05pDQgtiy8sg9m5goSWzeYVo93fHhb4M7ZRLvLbSZ8JXfhmLLWKpL8wZD0SMl8XztXZuBdAjyFnqO+00OysS21MphIYcS9WhAmEp2SvB2jvJNVklWfCcYEMghsc/PvnZ3g5GrrUxcBgZvn374V7RENJnOXPHWCbIpWuzQ9QtPKHNSuZNTA9EyHLVxJKmy/3orQ3ytvyG3AxuA7cQAxUjb7v1GmGZ2yCU5oDj3dCWU2h3KDm/E4kGhLUDIJc5O9GbQw0Pw1iISIAyfb+aboAj7RzdT3OsPUcNuSOr8iHBkAeYXl5JNwgRpTi56iAyNIn7430XSoe6JUFbUkG/x58q8z54HOk7jRt3XL7ymqXq/Zc1V0891+g12szIBldZzkYXLYUx0GbxGMq+XmRbEoA0ZATX//380tmNO4ZvFp7xNtbNDbXVfg3AkPk7FM9sPbV/vJ105+L5hsTgSdK534h7BGj3Qr19UwpC4BZj0L2Jzhy+ui1+DYF3NFtgZfM/DzXuPICP/ibcwONIZGvM49ggvwP7Jhi8YsyEIgeUWG6wRj0IkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7993!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142946157923"
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
  name           = "acctest-kce-230810142946157923"
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
  name       = "acctest-fc-230810142946157923"
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
