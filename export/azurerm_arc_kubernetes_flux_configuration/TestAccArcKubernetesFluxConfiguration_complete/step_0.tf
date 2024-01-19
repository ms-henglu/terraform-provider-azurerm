
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021537982029"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021537982029"
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
  name                = "acctestpip-240119021537982029"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021537982029"
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
  name                            = "acctestVM-240119021537982029"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2127!"
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
  name                         = "acctest-akcc-240119021537982029"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs2NLJLon9n20Ai0RZZajz1Lpl3e/E1pJCLcamteMp/6H3aktTV+PsF9XhBmcvNCmkQRgbblyYpAz5Q6Mc4BJBaHL/OjnYXWgUZAp61ALkgdzs2eFCIcbXIdHSjMwpf4BUGJCcjENtCArxBbaoNooXgi5mq8Vmv1+6ab1CCDhXXuZ6QA+DhzxhTLee1tv7hPsH82GE1k1si2a/y8PD8NHB8r2BGnsNW4GxHvQmDUIW3+wTAO6Lmeji/5dxdnGSvHuFCzhoumMEWa5sFNzFCQpesU+6U3AxHEopnAFREPZQIj7N+1eDQdvyD12LrYG40iuNedPYKW9Hgb6srsJQtt+KAPPQMAWWpBESuOCbGoimJ7Bi8qZj9my3M5GXpM2+ytMc65ELP3W8DX1pJAtYXoE8o0dxpubGVpaUAntMDbr2ufPMBc5SdPrJ7K4efWJnvkHqnlaZD5QP76xynJ9DcRTj6Q9E22fPmFdBMZZbuJgl3ZluQE19EwopWBa31vy/evEYsslWn6zZ2mK4Ybywt4xLNe5o3sPfYgR5wGXWWQZycigmUYURKu3PydyRvyvguzto47OhWk33DRXpYU24f8gkJT67vr35UTAPRYSBN+0b1/XDqAA6ECBVfEUOVSmxD37jrhVxJkEuzSEvDfyR4zrb1U9SpbYkFfqx7WMAc1tlhsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2127!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021537982029"
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
  name           = "acctest-kce-240119021537982029"
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
  name       = "acctest-fc-240119021537982029"
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
