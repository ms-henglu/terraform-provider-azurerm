
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003347441041"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003347441041"
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
  name                = "acctestpip-230707003347441041"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003347441041"
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
  name                            = "acctestVM-230707003347441041"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6061!"
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
  name                         = "acctest-akcc-230707003347441041"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv6780F47sW2yRW9RV+eiVmVnqiYKREfBr+7PDzHCmr0b4N39Mr+nbtejaZymCugvLGLTivOvz7G67MldR3Kp7/iJ0V6UHJOBkyJnsyKQWNvsYA9s8CU38BqB3Uzvu1ej5f4CWt+sGdATQWVNnlhsb1nisMtEGId6b5Syj7B6WAE8Iei69HpelIbX2/j2cnU9monOWehepNhH9wKoMsvrkR3/2DSTnVnJjY8hXfvokajzjJxWBhMjKscq052lJXRAyDAIgqfBBfRTxEcYEWp0bTYEdMAj3qtbeK0khfz9nJTSdhyJlo29Lnl7gzg6Py88S0+VVUzoX1iJs3Vmf0Wu5A5Y7R73NzOvrTo0KG/BKIrOXyNgnePTmveMezCMiygxMW95UYFdc/4ZOctxkN1JOFu0PPR3BOtd4Z8Yy0xsOI62nRI6+Th8q4v4/8VFKW6XuFgQSEjHko3lCvH46tFkIfF0IUWSwQ9F4OBvQwMNTHxhMbLpKlrfBEDCiiVIp+CrL3XpaKPFJ4tO1CNgsEOSHXLX/z428LGwsf+u9VKtEfVHMqgN7ZzfVIJNf3aLBn17TS8O283jhlJjDOz/f3jqUxfI/NvQlZpN0n8MvQMelfgDppqzOmr5a/XKoyEDH70KkwxuwI4gHK4d3N7MnfTe1NsZrlFgVmufZpqfDVOWF5kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6061!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003347441041"
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
g05hAoIBAQDGpfyKeoGkFEBTTt1sniscoBtOnKoEyLn+LTC1pvPMXfnMxd80tX6+
um/f5xMA2j7bqBiG0G/L1LOQpzZOltNy2oabr0Kk0f5eizqITqYV852QIgnkVvjn
x2HKnG2gvOHsIunxmYocqHclDxWoz87MyYElhMX8vw3HgPdvKj/HjUUapqCK++om
JnEOx295K9BGEB0fAvySm4MVTMM+tHDnsKAWwGOtX6aCVoa/wAo5wE9wYuxXcxcj
yp2YoIvN3tM+02SlVPeib3J42ew1TSxNJgm5JOE2vQpBjbLIqFXjqPCLdazUujcx
BE3wa5l1dY6oWIcE5isBrJ9dzSripFntAoIBAQClWxdMTLwsOECTwB5zE15DU/3N
x2mWRg4WO5p3OMSQFapgGEQpyIIGFS/CF2Tzs8AC2W4e/sUijUvZTK8ugulDVdYb
qDiA7TslcQdiBewvG+VB7Gy8DEpk4+8C9wYEjkM+rpeDQsB4CLeVSSFjWJoMs2wC
tcXnsU72TY8ZLCqYMsPZymJFnFm+czB61JKFn01GidYJ20X9DG08Ujx6MxEQUq7k
7VECJFDBHtKCQ9Q2htywlgaOVHIbXblmlFkCsPaWaUk4Q/MvbrX4DFbtIJmidlT2
vSL+rqd18Ug9l9v+zCpcWXzkizAsq3pK+GL7zLvGVSKPu29cbyZ+/3RSKGC+
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
  name           = "acctest-kce-230707003347441041"
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
  name       = "acctest-fc-230707003347441041"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
