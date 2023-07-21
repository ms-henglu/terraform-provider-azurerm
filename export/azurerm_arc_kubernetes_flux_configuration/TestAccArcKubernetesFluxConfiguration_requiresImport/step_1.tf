
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011147877759"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011147877759"
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
  name                = "acctestpip-230721011147877759"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011147877759"
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
  name                            = "acctestVM-230721011147877759"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5418!"
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
  name                         = "acctest-akcc-230721011147877759"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvQXpYMwnRmtHHBgPg3dPeh4SdDFIzBLbQTKPMbFXZFwHfldkk1NWEoXCVQiNVHfNooZBmW0MErs8n1nz4EwZPb+RQq1aZMTgeY4vUWVsOPKj9+Ao2MvVBJlD63s427i66ZIhZGZ4BHNJ7rNj29fzkN/fk51iKitKxFuNSroFhTPvn7/oXmijDOlB7iQK5XBygfRlwJTZcNgHh0VpnhlcYCEWx0ypp0m6QWWw00JZ9XUiQP8sAMl3i5Ia/Zh/Xe8x4U9vkO9QcA5sCcbhwgrjT+2VTeuGtIKCf44r85Wzmua/ZiJcGwErqgMBvJ22wx1SocrQgidgYRdWnSjcOWqtqTrca+jCNRG93W9GzZ8/HMFbnM+LKBbpQV3ZEZLXSiLvg7NxTJAr4hx86dYE1ns8vD8x4NMIWwemyWtQerT4kMnUBAuhgbP/ibBqhrZloAHgiqPmDI5d8UdOycaQxtyLQa91dMDKZJobvhgO963SziHCacvKwpyUrCldqJ/Rm4tmVDe9cLiYAduKOPwjM7zzyH1qZVQOKAXltbnwt6NsTIHyEePF/MmSkPS1eyrZUky76k+fWfAobaDU0uauT4s6zFPG6/SL7Zlajuvx3VUJkJ0LcURx80oITut6Wt3dbvAUgPUMshKfdxXiuCMpuWZ9cnRZM8CpIOOKbvhawx1LNCcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5418!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011147877759"
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
  name           = "acctest-kce-230721011147877759"
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
  name       = "acctest-fc-230721011147877759"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
