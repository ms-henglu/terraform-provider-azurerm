
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060239852308"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060239852308"
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
  name                = "acctestpip-240105060239852308"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060239852308"
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
  name                            = "acctestVM-240105060239852308"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8834!"
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
  name                         = "acctest-akcc-240105060239852308"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAziHMowcxy4LTt/qwnwFK+So5l0rSoDM/HLp52HIYYD2m6f2/3Rc2xqo7pDabXgYhuqNpxfx8TWciw/ZGyrvbTRjH/CtqXPnsJ1n3LWbWihZnOEb2ChC2yVE5S3SZ0Y9ZOm7PUeAwll/8RytXUbTDsAd9EuYg1QFYrWb0X0e4gyJsk1yHjqdm1FjP2Q4R/CNh2z5FVVAhKiOowrxChYknlOuYrPdBNprmJnypjnodLl+SLL4LtKDUrW3gWcIKdzR11CJr9fEeGnvwFQfh7AA/HPJBbZEk7KUJTsze+bsSRTtLUoQeox01BsWeNlW8OvlQGa+LOLf35NEfOewrNor4oAxGts4/qMd2JGKGMSQK3P9/tD1V81T1cJjAWEaIksJjJ5U23N6WpLI/BzzCm3JksGdnTkzHk8bUH9PRxW9BphGHJ+7X6hfRF8eKvwUKv6Bg2HTAhcfM/CU2vXIk8J6KgR23zSe1rXe07qiItKCWzACF8fjh8/9yal2YVs7EAjz8BYkrVAVYqnPYH9UFDANxuPXS7lKaVUxnzugot1tqj/47R6n//vwqwfTgtyArvu0gkb3rlamvdq/1Yu4Y+xWM/j5exyd/LOgOtxvB2hy8hzce/5s1QCp7EVYcTAbGwNmCsbpV2oni1aPJ2vX3LeoxKuW3EFQJORe4CjsVN42ZQuECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8834!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060239852308"
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
MIIJKAIBAAKCAgEAziHMowcxy4LTt/qwnwFK+So5l0rSoDM/HLp52HIYYD2m6f2/
3Rc2xqo7pDabXgYhuqNpxfx8TWciw/ZGyrvbTRjH/CtqXPnsJ1n3LWbWihZnOEb2
ChC2yVE5S3SZ0Y9ZOm7PUeAwll/8RytXUbTDsAd9EuYg1QFYrWb0X0e4gyJsk1yH
jqdm1FjP2Q4R/CNh2z5FVVAhKiOowrxChYknlOuYrPdBNprmJnypjnodLl+SLL4L
tKDUrW3gWcIKdzR11CJr9fEeGnvwFQfh7AA/HPJBbZEk7KUJTsze+bsSRTtLUoQe
ox01BsWeNlW8OvlQGa+LOLf35NEfOewrNor4oAxGts4/qMd2JGKGMSQK3P9/tD1V
81T1cJjAWEaIksJjJ5U23N6WpLI/BzzCm3JksGdnTkzHk8bUH9PRxW9BphGHJ+7X
6hfRF8eKvwUKv6Bg2HTAhcfM/CU2vXIk8J6KgR23zSe1rXe07qiItKCWzACF8fjh
8/9yal2YVs7EAjz8BYkrVAVYqnPYH9UFDANxuPXS7lKaVUxnzugot1tqj/47R6n/
/vwqwfTgtyArvu0gkb3rlamvdq/1Yu4Y+xWM/j5exyd/LOgOtxvB2hy8hzce/5s1
QCp7EVYcTAbGwNmCsbpV2oni1aPJ2vX3LeoxKuW3EFQJORe4CjsVN42ZQuECAwEA
AQKCAgA0NvmYPmVNsOkijH0a+f/c1+ZYvZpW/EQ7ab0dp+Em19clJKLqRUwZzNto
wHBgw9rdZTGQ9mEiVkLHMuZByo5FnEZkSTcbMC+y1CY5uPgVaJFi/w6qBAvZORrz
Uyj3nYEzvQgFLG4CWXQVLxRiXRDI0UzMccDVVA77db3nOMqzZQ/t0B2CdEMm/QxB
ZkAGB4xtNfvoHXEZNIk2MuwC2XhOT9OP1N4PD/PGwgNNVP95VLo5XTan3amh+NhA
xFdUVNSYFNQWK6q9eLGbEjEXUASst2z9bSvWSgPukxTUW5/IK7nrwA3msapR+dMW
3mbc5XR13TK9/lPsAVEQohNcMJ3DsHEcVDelcXI3x22INZkSUlhpvHFmR+KTsmv3
4Tm5t0A2tozYC8GLxsBkDWYh/ektvvQ+m/kpR+ZxlaNaOui+Rtods3CMKHZ4204Q
PexDGTBADIS2jC4OqSBegKxJlTrRciuF20leta6B3nwHNZb88BTtvi6jTNaPblFC
t8il8zfdRR/KuhnV4CtTlgjy/xGexziFylLhVa5CRCgJV6HTTB0SRBV46f8eJuU9
8//KbKVfX8J2htYQhP2F7bH2kGHJ7cx4K6G7LFaj7LAaFra5BxEqKxLhke7SNS7N
VgYviZdQvWlVesOhlWKHO5hn64ATkUQa/tazIhSv5FfNT3p+sQKCAQEA2mPcmlsM
ggBhYgvjQ7R2IPX94gew5gGtUnHJktMnAoucIon7NncEeAZgXt6Uh6BKUowlgd+e
MYfb/SqQ0NyfMOmmU3bSxOYplxjJVTlD3+KA6B2Hyp+YPbmhir6r910ZTwDFzNO4
NdPv/aGlIxi/K7W03BVzAYCpsnxRU5h0l9dZ/ZGQJGXMdpd78kozuXpdfTFCo7rd
TI9+ITpJ3mZL4Fmz58HHdp4MLDknO/Iv+WFv4gH/GvJ3DpJ76ZxWXUhYggLCkPjs
9RIt9A9cDVvpkJTcsm47qv1r7vlF5Ar6NHNxQCbVo3mb/sYepW1Q7wB0VK7TYTmg
HS7RtbaERN0tXQKCAQEA8aGEpK5J0KsdNA4t8BvN358Zg6zW2pNrm47Xh/81yuJi
1VQoGtw6nY8qUQjgaScwfgabOggXnakDbLqbXPrt3wVXVIBquB1KKX3bKc3b9ICa
7RzUneIT5gX1YdfyMLV7t0Ktv3gAh3Q5RD+Iu+2QnbOiy5ZWt2GQevxsecbQR74Z
X0PXzdF7R+qsWJkOuVNQSyqfSYRx/fhMi55TF9anDqe6Yqde/diziDxn0xyba7km
ER3YOt7+74XNA8d58+UQk8AdUkIbxV/vFMp9lbnYJQxsN0Sv01PSpbbO+nJJkgha
iuYMv2kE85zK4qPuiA8YSFgBcM2fyFgfG2sqZ7fPVQKCAQEAho8ZEZIf9sm9NugU
M1cxocVvlKEggddur2mkxW6Mjqjunulde4WBn2JuZoXGBnrg0FPBmG/rzKDlDuv3
JnmJLF4KOUrxOpiF7685/eS2yW+J9XqcfGAxMXb67b3lvxgBzAex2C5rRd87845x
bVqGD6x5r1EX90kLRgoLIfLBg/0QWYgixAplHHzhxbuqexHGIKkFYlR0ngObt2Vu
tjVZcvZSPu3KtG9VGLpuTiU/IezDPwHz6OqUKMpgxuOo4vj8b767mw+FEMsOvV3p
XeHP22GdSeNZqFVU931nbsbEuySWFuzWnU8EqsnvgAYG4/vnsXW2kCUtXk3GsKuw
e627kQKCAQBoMlOFxFa2ciOcwASVRxgnN2+ENbNM/EdqBFXzIl2rCKbAAZNtycxJ
B2SjHyXOkoS5w9WKV9T/OtPsPigjF14eTypSmTHsBU1myQwKYehY7mBgoY8aKlSU
W7tuHvYkhQ49f7Z3G6N2xeqwAInRKGe1abJpAoKQf7UTI+kPNmm4lkRQrWvRKGV2
JL9/UTllN4UndNDNnhyd/UXc60A/xmOx0ShxxGUVKC57MDlBc1OeR3Af73PAJ0te
NJ+s4oc3Ym8cl7rNLw7UtULe/1baixKnH01HJAqCIeJzbXqhy0jofUu2G/AhVoM5
HkLrKvAAoinBgJnWcAVYGpAHfdYCdeQlAoIBADNRGzVBPDHuzBSJOaaHKoX/WWF+
06zH7URXTnJsj+5BoIoTFxnrqokZ0KZN2FAxfTprudu0DJJP93Frn3AzFKx6RdyR
90gS84fnXUvmmVCD/G/jRy8nnMo5M3JxuJEysmpccLUykZfDXYHic1MHQMth0Qx1
6LEeBgLxv4NOB+NEWlw6WXhJ1LaH6r8t0kx95GtzSv6wYlbzqlClFracYXQdI4HB
UwdvXA25AtCFg1RBUqHKmO2TnGQQaiqEvDaj8qJxrQXzP1hpU0xUW9tyP8u92VGC
1Hn43WMqvcyfp6j8cdqTbb2cFUk0zz3/6RAocGxW784ZqcfCPjBw1/pL9nw=
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
  name           = "acctest-kce-240105060239852308"
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
  name       = "acctest-fc-240105060239852308"
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
