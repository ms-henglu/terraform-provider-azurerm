
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122328979591"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122328979591"
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
  name                = "acctestpip-240315122328979591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122328979591"
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
  name                            = "acctestVM-240315122328979591"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4099!"
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
  name                         = "acctest-akcc-240315122328979591"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyb0DPQPVoNpiqmg5Wrot0jC0Klbd46Kw5jKhMQ0Xu9W/HmwfsclQq8E+JVNPzxgRY0Wt3Hp/R4uFo0Iye5l43aAuYsIccqWsC7moEM4aQGfcDPrwmrZAGyLEsgLHVQhZIlSslo/0TUnYfl3GB6MN/GKtNmpocNltKsI0Y99cqhp38HzMSx/Zmx1DBX8bZ64OIXd66CDoonYFIR9nvYzKmnjjecWzrK5vt18BH7GZOwH0Mo4qyT+nI2d0p5jhZO6K7LPdOvaIJN2xcMNW2ZFoqCGu63Ijxt84PvsrTAQVS/4EfP00j8Jr/mi/DtiYy1CLH/aQtJE2tIqGkBnyN0ZgWmJMXL/GtrYCGvvXWCGUpYu5MJVYMtEw/fm6dKD1kcTOwva6EMmnYpWb+j8igiQYwqkyCYjojYl0tuzxC+GdOg5RJQ/B/E7dvRJPiF8w57Kpu/LqcED3GoenpTSb0c//E+8MPmD5zWCHqej+nmCQbAgAbrTR7fgi7fpfZHnWRElwerjzMCeDcgUqfGE9415qHtLrOVrI9oY+s4DzAA4hYvdS2IOW9cjFI1N/450+c13jKLdRXc7CI2X3VFCmzzEBwA+iqPw5LkFZ5RRH3DQ3YX2QD4Df15OmT+rlYbYPXf/k2td5lQACqTMqXe0/YY7IP8gzix20dxXzcy+ZPMACUWMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4099!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122328979591"
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
MIIJKAIBAAKCAgEAyb0DPQPVoNpiqmg5Wrot0jC0Klbd46Kw5jKhMQ0Xu9W/Hmwf
sclQq8E+JVNPzxgRY0Wt3Hp/R4uFo0Iye5l43aAuYsIccqWsC7moEM4aQGfcDPrw
mrZAGyLEsgLHVQhZIlSslo/0TUnYfl3GB6MN/GKtNmpocNltKsI0Y99cqhp38HzM
Sx/Zmx1DBX8bZ64OIXd66CDoonYFIR9nvYzKmnjjecWzrK5vt18BH7GZOwH0Mo4q
yT+nI2d0p5jhZO6K7LPdOvaIJN2xcMNW2ZFoqCGu63Ijxt84PvsrTAQVS/4EfP00
j8Jr/mi/DtiYy1CLH/aQtJE2tIqGkBnyN0ZgWmJMXL/GtrYCGvvXWCGUpYu5MJVY
MtEw/fm6dKD1kcTOwva6EMmnYpWb+j8igiQYwqkyCYjojYl0tuzxC+GdOg5RJQ/B
/E7dvRJPiF8w57Kpu/LqcED3GoenpTSb0c//E+8MPmD5zWCHqej+nmCQbAgAbrTR
7fgi7fpfZHnWRElwerjzMCeDcgUqfGE9415qHtLrOVrI9oY+s4DzAA4hYvdS2IOW
9cjFI1N/450+c13jKLdRXc7CI2X3VFCmzzEBwA+iqPw5LkFZ5RRH3DQ3YX2QD4Df
15OmT+rlYbYPXf/k2td5lQACqTMqXe0/YY7IP8gzix20dxXzcy+ZPMACUWMCAwEA
AQKCAgBTZg0xqyUkk0OYuO+E/1S0AShqHHEsivRgpeuXUJdQMqQI2qAbqmLsLj4X
xiJHNebySDsA269Ej3xWqqYeDKs3y+GBOEf0aWL/kefV0q5tk8IXp6HSA6fqz+vK
v3VSRNo8ZA7ZS3euf+m9C90zCQheHxkGVuUISgpkU9a+tvci50BQLfdy0x7tjiJH
4m0c5oq28SLhVcF2cB3cvJPxe4PCall33PBTYeWTQ/Y9+PikuUEPqVAs1GCvNTS3
mG8Nf8P06MJ7frF3tCKHwGlmFkPSxeH/ObdqnpstBj629TUsrj2CwlZ5W+GzUfAy
Hf7Ehm6NbywRSbr41g+dAOzuRuzLk/dft4zY5ArIlI+/54pAIBdOgFe4ZWAZFd+V
fYwZLmNhJBBp831RwxxYnZq+mxA8/TEmDKgdx+KoTknF3jIy4wMdQIddHBi2f03N
D0bU+8xDFFdGiqxSytkxHBY0VdHJBBO2FEv46NfOufTC0IN3ciBdAEoeQBntn3t5
LwOsd4nYx1fR39Rb14PdKvzrGkNngEU6f4Vs9sOrisbxmql198+onXuZHxBCJQ6r
hiGls6SW4Pvl03WdK+jsKSLiptTVUjtQ7bvv+/XPHFKXu/6OApFHyCyBkeNxzx7C
sdNI5XAv4ywHo8clrSdkwcLJanFeW0P5jIsLFa8HvC5IkoBo+QKCAQEA+hLwEw1x
4EhYCZfmcJraFsUTAwjLmnkKkyY8yqylruGdMQ+FXzY8/jS5ahc57zQxzrxWLh05
V95SiSnxpHlUcVHHR6cbX2UAQfILOC96NdWiXQxlWFvYD/RJWan6dKqHaEcbf3Qb
JgMMLcnxlgjPrJjBxX68GLi7HvpCjLv0QTrbAA627mYCmNOLrlWdbbWCZXmcXEju
X2bFbMZUc2H9MDUDnuzvPYc1OCpfUFIhPDv2fX+e1GMfgvveKhoDkwfRDPxQERL6
UCOhMiGLzMOBATh8YiEAK/cOZp6/P/Ma/cqt9o1dvvT60GvUS+zFcpJuq3kU/Cho
CmCmC+b40Eh0BQKCAQEAzoTZUbwNWg01aEy5k3mHU6kwdpgnKv9JMBcQQ3/hOWbd
HXXgRxAHPy/ilFzaTGTQ0/n7wRY8ZE4iY7OPhPEqMQ/0x22lMeY56IEgd48Lvet/
JXWfoDqaIhfqLpMB+w3Oaki656Ay0iXUF93qwTEH0tnMbnMnzE6yBr7wOF1qFxkY
NphvlqhArjX+qnC0nSml1RA5q1c8d/wlFhaJjeMUivCWCZ3vRj4A9FSh7yjj3BGC
vBzgVFIjyAOdg6jLaXHxcCgsl9bYDWQBvVbj+Nc2qKoPgtNscuQRojRrN6TIWEHA
+lJ+LfzNFRx1+/+9sIXSp+YKrEB68fc6592Sel7URwKCAQEAsMEF81GDddVsdItr
E5hAIev1viVPU8XOFafnPBG/odZR9sVTrbJ2de7qRvRXvJ0Vv1wbRcjeKR85Ez4U
T/56EwaMZjbVAB4ximr8RyA3rylq8325fDSeiNhPqBKetit6PdhUtUdpkPqCdzLP
kQ51SzdFbsRfStH3YLPeqf6HbDufY3EDF4n+t+p+RiC5fzvWCMdmH0xlQAUx8epU
8qEGBjbSclhh2QliMmqwp+MFHr/7P0UfDFtrgHdp1jRA5oGV3ynPpeHWDyK/4uEX
IQnmeuhj8jAFIQ4knaAC6b55C31gbG4LHtelF/+/NFMMVCjwFD8m9/vPXdZmRu9g
Wkd7yQKCAQABMowACVMafpEctbUtwbqjJYv+ZAt2GFzYRon1mjw4FPybOx+9yb4B
A8oQiilJ4BvF3uEy0WowOrPAWD4wyyUve6Qzs9MNYwRa8MS7bLzosQDfurreNvjF
0dWtx3RvfDkCLMHIrgkdZtLAAK1nyVz+P/0Ldud4K8ykdV73NLN0xtR5HJEpEnit
ieqcGmMxthgcECgFclALcg7U/fR2OibYV2THUX8drSZcRFFcDaSklgVoCdLTKlbC
xiKXrNbhGaQIvnLjvn8qNLY93s8blkPe3n2QiKFMWT4w7pTgkbgHqvnveaL5qUmX
Ib8dYvI6n8wE5TSSox0TYheZWJOM2hfpAoIBAHMJ2clTZnhrB/eUmE0t/aGzNwa3
5hO2UraawvFCtJkeRVs2Mw2+ICDsYB9OYsLv5wA/KLlWcObm09VcLWOTaCH2degc
UHMQ/Ij9rQeMP64iOJlB88AG98K1ScJjk6WW1Acq5eC1a/BiH34o37K96usDYGYB
LsemjiXBJ4xZWF4vWWxkMcRT+j1HXzQyr3JG3MFTyYszZW0c+m8DORwcei+k4uV+
XPAWL9picQS+epMsTbvz/RFjfwPWvgGgT3uILgPc9C5MEEJ/rWeJ3HrsifGijulR
eCoYmDNft0E2QROLq+ckNppq3999oYuVGV4WL9+lY5ASyUOoQo8BThe1Cdc=
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
  name           = "acctest-kce-240315122328979591"
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
  name       = "acctest-fc-240315122328979591"
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
