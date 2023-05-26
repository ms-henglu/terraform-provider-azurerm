
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084601898114"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084601898114"
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
  name                = "acctestpip-230526084601898114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084601898114"
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
  name                            = "acctestVM-230526084601898114"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2194!"
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
  name                         = "acctest-akcc-230526084601898114"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoszamdZl4JWjzmz/COFfxSiZTe4PQraRAVRwwSz+29s86WMubQQbk5/Gna2dMLVsyD8IX0ihZrfoNSbckpLcpEf1Bx7LqvKl33+MOe8z1ldt5fnFLN9Yo3Oh/XftzMCyyDbMartfBlODCDo3NrylREKgMMvhQtMh5hz/l+qvlSGTooVbMi+knjFDv2hzNPYrANia9L7BbAwFX297MbPy/bxW1VKLrIE5yV6L+lu8QUzERtOCMlQDgpAm96wmMnmrDvfvc9swS/ih90Q6deU9ziqupFwvsyW0i75h65Ju9GcvIp6wQV01Ph5oSsH0cU3Nx2bGyepltmJm43lw2yvmysy5+ghqOLCrdkfh7Xf2xDDKjdysBk7kcnv1BcKFFObhDg3aPLYOZ/fCnPZZE5p4n1JSfx4LO8V3+mW+XyhoiER/a4pLiOYxPJJpNgkXGshJR/d7HjGmXYrBl4apqA5BBXjDL87B4DzQS5Y8PZ21/TPjQ7Sx7lGpbNl9rSpkEaxi0BI86gY0YIOIfb9FckiYO4CbYbtC/0THTxAFmoaTFiwlQfuu6mg/pBika7NnobK6wQ4Dsz7rmUUddKo0cDJACfmkIzNm99er0sLH4MbsXjzma7f/AdR5q3lDY0lNWp7Kl7Q72KjQRHqmU5cgfX6OuBWfXvZBSag+L+PHXOsV/60CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2194!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084601898114"
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
MIIJKQIBAAKCAgEAoszamdZl4JWjzmz/COFfxSiZTe4PQraRAVRwwSz+29s86WMu
bQQbk5/Gna2dMLVsyD8IX0ihZrfoNSbckpLcpEf1Bx7LqvKl33+MOe8z1ldt5fnF
LN9Yo3Oh/XftzMCyyDbMartfBlODCDo3NrylREKgMMvhQtMh5hz/l+qvlSGTooVb
Mi+knjFDv2hzNPYrANia9L7BbAwFX297MbPy/bxW1VKLrIE5yV6L+lu8QUzERtOC
MlQDgpAm96wmMnmrDvfvc9swS/ih90Q6deU9ziqupFwvsyW0i75h65Ju9GcvIp6w
QV01Ph5oSsH0cU3Nx2bGyepltmJm43lw2yvmysy5+ghqOLCrdkfh7Xf2xDDKjdys
Bk7kcnv1BcKFFObhDg3aPLYOZ/fCnPZZE5p4n1JSfx4LO8V3+mW+XyhoiER/a4pL
iOYxPJJpNgkXGshJR/d7HjGmXYrBl4apqA5BBXjDL87B4DzQS5Y8PZ21/TPjQ7Sx
7lGpbNl9rSpkEaxi0BI86gY0YIOIfb9FckiYO4CbYbtC/0THTxAFmoaTFiwlQfuu
6mg/pBika7NnobK6wQ4Dsz7rmUUddKo0cDJACfmkIzNm99er0sLH4MbsXjzma7f/
AdR5q3lDY0lNWp7Kl7Q72KjQRHqmU5cgfX6OuBWfXvZBSag+L+PHXOsV/60CAwEA
AQKCAgEAm12FAWtqrnogac/7VC5Bh5bHN2gJiFFS8UH0mWankooYB2Nv2voglzHU
Coa1jNaXikMdalGWNsEsCg2cUwV1LBK/9JufIvWO90xyNpfhkJy/dMp5Mem0Xcjs
v0jE2LLN6+TgELvgY9kvI5rrNoGx9wLefbMUtwFnSIREKGcASgJRMrix36M4JwA8
915nFBQZ1iThPNEPJl4SgpGRsE1biGtFMzAju+1XiKWCUNtbPbZVWoJfrkgfUWrg
xVy011bluNNE4fw8i0Qszh1+7SRpZ2e0Y4bWvtEtDHAUYwzMdtJCWXe4HakmNrIu
NaoD7l2iFLow3GGlz/j41/39hizPgxT9tTUVD2IjA6PWacxsoH/Q0qITuo1RReoD
2cB8N03HH7BZbGEEphu78M1+Dfrp0yeirI6JULmGYBcn1L5q9k4avRJ51YRCspoy
r8LIP27MehYgWkfp40+wtIgwaOujok9xLB7mxC2ioz1Xzp+kQgrsDn/9GhXI2D4X
ij1HNgnhsadviNEE5c0TI0XUulNE0GfuVSp3wMVEDhae77F2wM1O/aQXIY7ummEU
I8zPweoFkf1FMTpwPGH2U93kmx95BxgJIL15Yh5F4mQt2j/5VRJSOV+VRief78dN
yNdEW6QeXrbRxwj1+SybjB9ei5rNl0fdLfDNweWIjZ2CaBWgJMECggEBAMO/biHS
5ZQVqST7kdPBK7xRVAiEm4mREjq7b1zWuZsLXsjOP+Tk2zp7+xBaQiXODzVhazgS
JYUsoJ6cw+ddEVRkFS+FV23xXVcJAua0f/dhcqx+8v5M1oj6w5Cq7GAnXEipRIYB
TYBnD1HHBhOSJ5SQoyOHI2iucw+SccXOQiZ1TsM5Tc47In0GgpdKXsHxMCDoqdO5
KNJOYAs6hH4vVaeA+mKMGVH9x2hYSaN9fNrx2nPk/tJOhoyY77AVLgD54ISe2P0d
Y1s1kJHwuhamcxVbD5PJNpnM8urWBfRg+E/54Rk1paDqJK+Oz5LAE8DbY9/NFhhh
yhf10ItVr2XcPHMCggEBANTpNyU5EQC9/QwAsdCFDB/rsTR2rHPwV5BcvXoW6X/X
Ef91khdc/uL9XQepcBndhaDyCvybxE/JUFt/u3MUjGGpeFrxQLyWWybKUW8KgwOt
UHf/1aMO9DRzDJLB9DbKsD+K6EV3RwL7NXTgDCehojdVJIueV08Aa2KkZ0BdBG88
kdcY5La0tkG9UEGevCE2Uj9JKRm3X2YTNtFD0taoDHhD1W/K1zfaWZRGFog0euwO
Vh6kYDSt4EjYpmzTYmWVYLnqRaqOWJjaD/v9NQotE8anq0+zcgtueagLMdNlVPqN
5up2IV7AMmHDyKvbKWRE54pI/np6G9/gKkYbVtgq618CggEAPBnYnLX+GzuTVXGQ
Uq3q2cU2we7FOrW6HSJTjPO4xSv2jD0XTRYfYZOTgG/WA3mDHeatXufjcUJEhq6n
T7A5k+muv4p3T6BeAk0YAPHGoJPg+6l2vjGlZSVpSk/Qh61OHlkqWuKngxchkwBC
k1u6n1jRXiUt8AQv+8YA/LTZhqlZ54L+qqVpb23CRuVktrNxDYmiKwmcyQWbY5cx
+vRZnjZxqjRNyejbguQop/Ptk+PSKOdUfgnyMdT7Mtst5srR7qY/BWgyi1yk6Mo6
uJ2elB4DaGLNSuesZgIUjfYAB743KOBZ3FBHt0dn4CztY7d4sMxtTksoG7czsrQ6
SFIYlQKCAQBzUqdGCDUHe+EWoUGvOoGowJdJXYZnfiVP0ovnF4X+ctYS0vIAqaR9
+tJrFgHcYLrCxJfi39Rjix11kihMWzL2qz6/s7Fm9OIGjsuxI7Z3RWcyuGZVXgI0
bqS+0UOgcgUpReotxj+2g68e0USEKu6cngefgHK2HfoMghRTLo76WYp9QcSQmi2m
Sg6wnHQ2YSAHm28huMt5lKq6iswm7PtkIQn49ZvBawneYGBQAm0ac2F+U3aw0gWM
L51lkNHZSCIOUbDOgy/GC0dhLHOQQX5Wufb2wrHhM0O+G+IvKNHwrPAIy1ej5OLl
RZDqVVmEMDZiFsuQN5flmZwMQT628/htAoIBAQCCshAVG94bvRGMpG0XKl+1TyDQ
SG26qX604/tmKZTSJR+6jvoRq9Slzs3GcUpd2uCzbeDo4oOWX7IpZMh0y9Omqyep
bjYAdAGqwYJvYt62gpKrmEcSzlB7YT75kp5LRHMSfu18cW4dcWxAwLCODQzw3woX
LcFRq4PktvAH6dgq9NRzgD6ZxuJQYVKd9oqI4sgCkQ+ITUPfglJbV/cgVQBGJTZk
5SZRJ0ZqG1YUZarEevCfOo3rfeFrGi+oioAkl5OjMr2qZBY0ahHhOfCaqjkj/tQ8
HddR5BOpp5saZ+iYnjSDfM0kCtXsJZeXvC6ruU/mGtJ+XWc3vb63WFhjKFQN
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
  name              = "acctest-kce-230526084601898114"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
