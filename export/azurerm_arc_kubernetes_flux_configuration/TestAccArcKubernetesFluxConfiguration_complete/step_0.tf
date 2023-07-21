
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011149229867"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011149229867"
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
  name                = "acctestpip-230721011149229867"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011149229867"
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
  name                            = "acctestVM-230721011149229867"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7788!"
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
  name                         = "acctest-akcc-230721011149229867"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwgsHLf49cK6mZG7k7lfdvHJ/LJB9nn2eww/+arO9zFd/bpz/KnUQz5H/N//Y4Z2vNwJlsdxuzqa8Fa89XUho3UWy0UEqK3sc8Aeqws+wlpYtEjsRyU5QlDszDBQH9fCECYUcBXB/vu82a26PcDEghPRz7EnSdmfGtjZftFrex1yC6hxAGLxxXOBEv9YkpQ9fpZAEV15XqraB+Efl4F31sMlFnFv0j+JqEsUf7EBA5qwDsZ7pvRjLQnzxQYHBxYmOTdGjz8WZdlnnpIDWZ/Jhe08igWLmBjX8fJqGCVqLnnblxYrMRN/n6Y50kJVC7JnnEZoFA0j4k1UeXysSqXAwgEcKDN7cWRJNO8YklOhDZ3YwVYwpVKW3kDfvg5q28Pu7cgh8eJjAoTnrXrzXA0cOQ1Prh/EUO3436wOqdPvRcprYNKM83Gb3w9kJO4mRl6bd4KAXk1bVOnqHpA0RZyMKMBtVhexyvZc6pFmVlA6bo+zP+PFzROmRpmblxojIcON4Zq6t4Iw+WZzHKUZ7VlBf+9UlnMPQcxzjid2K8xCP9ezvDHl4OF3lqdH0MsoAXNV9IWCS6I9lRRfdS78YGaPpOKF8Cfaa6RhovdV6pgkbtd7iQYK1Wsr1OCZS+kcx2oWJ5x57kBr1sCX5EbmPd6ZC1vA9J/aUP1yBgP8xHhbgkocCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7788!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011149229867"
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
gfrrQQKCAQByRbUkklrQ/1Hik6kT37zgfDZaO1rZv5RjyrLIgdZENGwF7cuSgRGn
T+YgSTpoZkywyeBspCw0rb9o+ddB1IazKWddtYwafh6NrH+ES6q58dHq+bA1lpWW
U40FBzKDygHZYSHyLAxrOUdOL/k88THxBoMHzFSD4558v9qVYM5/aziezX4x+qip
ykDO/4D34iIg3mg/Vw2KzY+N0vBsWOhBRFCYZfQ2VJjVYuP/qVadjYFdlyqJnqyn
CxyxpBlzqryCsv1UMGuTPUYXrbJQ2jigr2646pXny/vzP5S6JE4tFtD55jjpZtBQ
26I3whC4g2ngmP7dFlQiNPin0aYLY9eDAoIBAQCZRfwfo/r9dQDH0lfrF65xLMeP
Sw/TmsKdprg0CSqhfR5ZSdJc/hCWtqcPEvsaFeCnGvsnrs5lDC6sN/rVEKjRiN3+
r4lXDb775xrLRhZAsWvR6cThBq6lWk2UZHznq0fOEvi2SIklK26lD2wog/U5Mkey
h4rYDrrqXEULi7rrCdNP+pme/3uP/QZez5VeKpsvhT9pDFnLhga0ZvfK8sW3Hf/o
/YSSAkQZkMm+1MZxA4e4GhQLQpP0PBqij17ZOTVcgXlMbq3abJ1KU9qZrE+rdkCT
qLv9ZIPpg/t/TrIJngO6vWTKIxqvVHfiHrPHNZIPrlq0tMgomrVtjw3h0drn
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
  name           = "acctest-kce-230721011149229867"
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
  name       = "acctest-fc-230721011149229867"
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
