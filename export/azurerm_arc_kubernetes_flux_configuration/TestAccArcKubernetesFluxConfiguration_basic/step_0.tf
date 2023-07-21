
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011146889656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011146889656"
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
  name                = "acctestpip-230721011146889656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011146889656"
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
  name                            = "acctestVM-230721011146889656"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8811!"
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
  name                         = "acctest-akcc-230721011146889656"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmFeJQWrNvHfyhB5I26LYIR2YOHRN/+bdipUETwg3PIiwBN6rdOkiqEv4qVOlSUAwZoUaIcaoar5f/j1FWsm+Au1vqWOC2wnDz1lRVIuWYKPdMGnP+LXs+Z8EQZ7nk0h/NU1K4/rovQkHCQWZn6ShjfiN0rJZ3XCvKqZjPhyGvVNYsMUT2DDd0kcCXunZBDghM4uoXQHsQiJfapM2+YD7wQyDuCxmDeG0FegXk/hhXToQUfWqukGqlLipbnWqcbwLa08k7NxtO8JQNxKBKr2lhjLi4OAS1TVUMyieei+4Qthj8LlphKSkB7jAdgnJbrtRRThLbGEHbxTPjyYE4xmSzWYyj1NvrTVza9fD8fXoCWMSbQFur+qxCzSOjlhqMSjoYQX/+kw8kwuOoudV4rgOSho9YG+8c9Z8irBheT3Z+a6hEQ1EHjXXwEuQWVGo62oGy8oeZa+KCmnFyeiJcn0eoPTAxQPBxvxoqhAbIgPu/BY96WnthJEUZDwgf+NbD9AUY2fx8TcbX8HmK7XjEkjsimK0RAkokeYFkBxSy1YRYCkMHh89kJQ+ggKElcksg0KQnDS5HAY/ieFswWJkEcKMkmRCFYEfjixffr93HrOHeSo9UaYPmlOX6be1B3Bz+Nuhl4fGB6oYMenTFFnm71QX1hQTAVfKP28xUjYeU3m96sMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8811!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011146889656"
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
  name           = "acctest-kce-230721011146889656"
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
  name       = "acctest-fc-230721011146889656"
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
