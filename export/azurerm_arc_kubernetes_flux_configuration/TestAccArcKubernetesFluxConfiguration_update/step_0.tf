
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033841053609"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033841053609"
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
  name                = "acctestpip-240112033841053609"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033841053609"
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
  name                            = "acctestVM-240112033841053609"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4097!"
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
  name                         = "acctest-akcc-240112033841053609"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx5bsjw1jkmJb8bsLx0z1KuM+1umFF9q6yBvoKf/yq8mXgBl9qrzgSnSg6o329UVV+uPbvWC6Y7gzwab/mcZc7LlDDn1Hde9CDs8I9T5iZnpgnOz5pqbkRoyWjE5MUE//nQPqfebkY/UEKgsUZWjgYRpxRmiy2K4suqIAR+jW6JgTwnqjFZv3odSYhHf34Q4jSDb6yWp/7bj5rIEmDvVILcDt0sxhIvLydo9J8U62rrXR2W4CSHwjQHTTWv3JkhCcZ+9EBkhtIqGP82nJxvQ3Bw2xMWsv4Fyq83rRLjcbuBFjxJSp+sKQ6CD3YZp8mlyNp0PcYFbEVMmah3kIGh22VHZqd/ZoLoKNjzAUl9mCUFCwm/RdDQonMKN+2j7z/SAe1NLfLf5o/wc/AmgDFdWgV1hJ1pPibMwaqEO4dPHQcDQSqEO8QeuVBxfxUke/rfOYBJ6Mgcl5ppqQkKkJGCgKG1gVYP+ocquEDEL03Rrn5J9VLqiQJczCtUmWEjijP75xvd2i9SsqffwifJWRWKFToSWb3Hyhm3BJygMhmUpfexMtcjp6y+0cqMYZP3Gcye5yMvHOOONi4crRFbQNDzRZ7H+k00mOzH+iWF+tX1dmQxA/m5NgUaLwgJDdd4rmtqVz4jSSB/ZApXGLR7ldElyHr2+6+/gEYgNfMzDMq0QeP9kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4097!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033841053609"
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
  name           = "acctest-kce-240112033841053609"
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
  name       = "acctest-fc-240112033841053609"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
