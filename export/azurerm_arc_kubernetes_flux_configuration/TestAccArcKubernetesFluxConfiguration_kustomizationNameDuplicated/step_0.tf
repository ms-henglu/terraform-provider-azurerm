
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022923422507"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022923422507"
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
  name                = "acctestpip-230915022923422507"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022923422507"
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
  name                            = "acctestVM-230915022923422507"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1291!"
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
  name                         = "acctest-akcc-230915022923422507"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxisURy5AqAhRm5r0LKE1x4DcFQHC1tHyUTj3wtf8IYIhU4UAFUnq5c5y58FLcbwhY83IdVnFpuyhNXHAeNbsAGnuNyOcXNFaZ1LDIvALKy7bW4NgrQ+AXlskxHUnbGkpxGQ+jeMerPtQqOHHLGAjB1nc7DI/e7FuvvoxIjHnS/8/vSnM/XeQNqyblMO5AlORUMxqaF+QN5Zwd+/GPkslbmVCyEkzFUL2M87GRYmTe1imAw4QrpPqgFh28CZ0JT/QkY/N/DHqSJi9YKuXHTXmAsAtzuTkOdSxZpHjN1VPC3MWRgJ7oERiO/XOJK5euM4vj3CblT253iTYZjhFkzMF9EAm+EBWodkti982v4ZGQLw+T+V8SY/MT8dZYEldDBY8U7p5KqrFIegNNQ2O0xGwp2wKVovjdI0+c4Pr8G5ZG55b1X1XcqWmUdIbDfaW2HS+4W9de7dVloc2D1XGShbzyCOKU91LVbglpxmd8xqn64upwpP7CkT8QxD43cQoa6QiH2a/wEsGhFCe3JOE8zSR5dtbAi3/kOT4EZ8CKV4P1WnbxL45Udc7EWvMHaeonsj/wUcvUUtPpJhmr6Yz7J46vvfulRiZsoDAv375Pq4FQ5+EN7/qrvuvPavSJSe9WUokONSxxr6ILh+7b0jlv9jQPtqZG9uOgkgbQzRGulvh/kUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1291!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022923422507"
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
MIIJJwIBAAKCAgEAxisURy5AqAhRm5r0LKE1x4DcFQHC1tHyUTj3wtf8IYIhU4UA
FUnq5c5y58FLcbwhY83IdVnFpuyhNXHAeNbsAGnuNyOcXNFaZ1LDIvALKy7bW4Ng
rQ+AXlskxHUnbGkpxGQ+jeMerPtQqOHHLGAjB1nc7DI/e7FuvvoxIjHnS/8/vSnM
/XeQNqyblMO5AlORUMxqaF+QN5Zwd+/GPkslbmVCyEkzFUL2M87GRYmTe1imAw4Q
rpPqgFh28CZ0JT/QkY/N/DHqSJi9YKuXHTXmAsAtzuTkOdSxZpHjN1VPC3MWRgJ7
oERiO/XOJK5euM4vj3CblT253iTYZjhFkzMF9EAm+EBWodkti982v4ZGQLw+T+V8
SY/MT8dZYEldDBY8U7p5KqrFIegNNQ2O0xGwp2wKVovjdI0+c4Pr8G5ZG55b1X1X
cqWmUdIbDfaW2HS+4W9de7dVloc2D1XGShbzyCOKU91LVbglpxmd8xqn64upwpP7
CkT8QxD43cQoa6QiH2a/wEsGhFCe3JOE8zSR5dtbAi3/kOT4EZ8CKV4P1WnbxL45
Udc7EWvMHaeonsj/wUcvUUtPpJhmr6Yz7J46vvfulRiZsoDAv375Pq4FQ5+EN7/q
rvuvPavSJSe9WUokONSxxr6ILh+7b0jlv9jQPtqZG9uOgkgbQzRGulvh/kUCAwEA
AQKCAgEAn1Di7JbyxCRr932L8JVqdwnR5dGUosAG3+W8yph5yzajNFIozvSuNDLV
jhyIWte0wFggYLfbf2ed8ymQY5XmBi8jpJCslLJ6y7ZtyxjQ4da548irYHal7TW5
SXgmSbICMjGlWMzPTKJ/JkbdqX9gqfhE9F8xSnBLaJ4cAjG8kgyTYbDJbL1C47HB
Ish3ZLdqjFrK8T5i402+/a12433mieo+1maC+wTqipwiKqWAPBn43VvhbXjdfnGg
rVE87vVu6JeEMsyuXc7t8VoCEynR0URPj5XVJeko9h0zXrjm432S2pYEbcSMdUgY
gsTswgaBlgAiFMmbNEzK7OMwjDbpARqm4Mw/VySI/MHYyIGnTTiuC8onaUt953sj
6qVL2VrTQlBvCLqLG619xyE6+i0HM92d6ZF7AcYfkCiye0r7ZzetQo3HGysziR7L
Xb22WFQHawqJ8tF+6prDYSAcove7fvVoWRn4P/w9fzTMMTVMjrT9ImzOKZLVO4i3
09HxskJj8RtcKLQE852QFCFTdq+u3xiGTdjNRDxEcNzZMG7siRj4tv9YEHT3b9QW
Zr7bGYDqG4BlQY7iT25FhsE9R5e/+7r/NtolMkUBZiDvF9HMKYxWDIezonK7IAon
B5X9RuPNgt38G2ceZvV6alZPf6c3hlz17vArBj65jv9h49jSfAECggEBAN+Crg3c
NP8p3NeX0NSOdQVZ5eY6YKPzzXgDkz5W3iumOBqhy9WFJ6Dm9rgUhRWa3fWOqoGm
ZWcWNoWVPO8LM/v00FMv/IQjzMLr55Bx8pMooNed6dsvnTGkDAOEnh2ar1sn1/TA
13A/a/712KlaNhNKLpdj8HKfniLqQsx4Iw6iBSKDkgkBrWmdD05pXwaiQ0+8j57t
Y+Z/nPyu81eAAdDKOAjyJpoqaUelZpIVrjwcom13tcuJaluWwzZwqrBxrnXV/fDN
Oyl5STFmd8+zAOFIlfo82//viWRCgxV3lcc2MY9gAK4j/cKZjQzVzaoMW88iv/E9
f1HfjU2xtp1ZNPECggEBAOL5XDfDkAyfeD9pZYJMDXutRjJRSSZtXjG9Ay78i8tt
xj9H5PeD0KUXhy6E+jgYHWY6BiT1hZ7N34JUWXxlN2GfaQH+NyZWB/aYqTFCuJXy
TUFGxgvLgLYiUdKKHHGK5WRMBjKfC9MlJSuMeeagBEqumrOqqRfKRDsBBH3rgGHF
0akAEUJ/KooC4clirC+ejq+CRkBEBZxlu+p/TZ6PPk8g3V0f6Sxj5Mz5QxHVXgdP
qfSIuGYF+6dK9m6nnd8iI2xuVFSsnCPz1jlB9jVLNXxjeEUEdKctxYMnX9nPJYmE
MOJIZjGxyI+oOHILVJHZgrPJ8z8pLVxiq3ClK0MhDpUCggEAM27V8LiQtXsDp9T2
qEMT6KRURBOA85mB2bEw6/J/c5nvZSmAR2U5xkv/0EJgkaUumHg5AlaxFPTGnRzH
hdaVItCmM85iFGJMlzpD8jhWcsixooxjKR4e1TKD1TdqTzOuUJKtnlPV/62Ig4Y9
UlNBCFVUvV+xEB9s+2ne70BiCNb9yYBvVYU+S4Rp5khXJqamSK4Cerbz+zG4hWkY
9DSvtkUieeSHP4is62DDZrB4hLquIfSfL/QyNltOFrP8g1fVpqYUppoDmDqhvi1v
Oqtdc3oJkSj6Ez4i5qBrm8AGBm6RHwYfgfMkTOiaza5RgmUPp22+r5vQNZ303UEc
3b6OcQKB/y79cRoaYrg6S6rVJy7Sj/gK532DVqGeAuJJP1966XY0Q9bWC5EyuP90
34fCAAuc8nk3ig4cxo0aEivpSp12VwDe/95pwwEsznk/IcgRCCYDA/t/q4DFoOAU
Otxbu4fGObeKBb51Lv2HsypQ6uvUNQ9BFsYbjuZd+cI9c7CeEPYs/jr+yJP7v9LS
xevrgbpaGTA8yE6FxqOabE0gDfHFtiCrrSiacqu+AqBs+nW2tsDMvWLi60oz8uWv
n1VJXmXTq4HHVa4yDiFjWfaAsXhXGbum3D9trLjvwPRmMnHlcOAHfhda5c1kASG8
sfLqZZfMcELIjJOG8t0tkFDB4TMEpQKCAQEA0aehpCmaQsWW9iNmhakV2sEJKWcl
WpOC9zb/mxrAtN5bJ4XuW24ZaynZL18JU7huwGU9AeNMpy5uTQmXei81WqnUJfh2
UzJ6nO06fOMZEF7mJbMthvmyFzeED2lYZWzV7vQEZOpp1tWSvmRRri3Bfc+xIKMu
uiE+DWN3gLgjVsOqw8q0893wUkXtOyGYOW6O0k9YzwzD5nYn0UEP3iDhbcnhZS/2
cVslp2OzrocCmmKCLy2Vsyic6qALbhQp3oFcYxfqvdsroSQOlu80Rq0R1J4BJBdE
27POAA/MVsKPfpZ8a4zd4dSELRGWfgXq+g5AnohFMSrhwDbj+cBBHlfxSA==
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
  name           = "acctest-kce-230915022923422507"
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
  name       = "acctest-fc-230915022923422507"
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
