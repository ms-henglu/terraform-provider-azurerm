
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025105660632"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025105660632"
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
  name                = "acctestpip-230728025105660632"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025105660632"
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
  name                            = "acctestVM-230728025105660632"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9447!"
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
  name                         = "acctest-akcc-230728025105660632"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA9k285YW1H57UAB+PB16zmSoiW8qv97jKp1X5+st2anv/3VwF2MYBcbUj0/wNCY972w2evAtOONJLIpUljeyCExDqJqbJRNj7GixfKqPo55IEoQe0T/acEOSa5T/lhLLf/LvPFVW94EKdZ6xRuqdZ1cE5tquIPPC6DB7RWpjKCz+OedPE/Zd7UQ3vMR8NWig9M5k+NcEjZWutQif6+jk4iWKQND441TG+kTCRD+ABZjqC7hlkycz8i1BulEit0kuzcJUYA7wetnhuvdnbM5PJfwous+NNdr7hFtyeMd6Yul4LJw6bnBzKlVnwGOKlJKnIlW8hy21cXwN5Krg1fuOwDcsZfSohJmYDtwLA9LIJgUQpMHhDdjPZZZXONODa+iSMfjiRAId6zN2K+EVDE0/RFtNHTbadeqzYDUQ/X7A3yYrlAnGjM/pSp3tfSqoW510r3r+KXsZBNHPgWI1mP+HyvuWEDGjlvO1zsT/LMM1nZFc8Ab2pIwt5y6JkAVuInB9yBaWQR1himFRlNl1B8Ni2RmUxHNQwRBm1AAFVt4SYtIrvNcsYd7RY90VOJoQLmGln9JG1TDp6NioMqqjAeC1IrhFUAUVSOAKX5JBKMTKWnXE8AQyn8grKoJPvvbj0dSqqRUMi2zzgpNorYaJ2e9TQs+SPY/215U0U8KNp9cxO3O0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9447!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025105660632"
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
MIIJKgIBAAKCAgEA9k285YW1H57UAB+PB16zmSoiW8qv97jKp1X5+st2anv/3VwF
2MYBcbUj0/wNCY972w2evAtOONJLIpUljeyCExDqJqbJRNj7GixfKqPo55IEoQe0
T/acEOSa5T/lhLLf/LvPFVW94EKdZ6xRuqdZ1cE5tquIPPC6DB7RWpjKCz+OedPE
/Zd7UQ3vMR8NWig9M5k+NcEjZWutQif6+jk4iWKQND441TG+kTCRD+ABZjqC7hlk
ycz8i1BulEit0kuzcJUYA7wetnhuvdnbM5PJfwous+NNdr7hFtyeMd6Yul4LJw6b
nBzKlVnwGOKlJKnIlW8hy21cXwN5Krg1fuOwDcsZfSohJmYDtwLA9LIJgUQpMHhD
djPZZZXONODa+iSMfjiRAId6zN2K+EVDE0/RFtNHTbadeqzYDUQ/X7A3yYrlAnGj
M/pSp3tfSqoW510r3r+KXsZBNHPgWI1mP+HyvuWEDGjlvO1zsT/LMM1nZFc8Ab2p
Iwt5y6JkAVuInB9yBaWQR1himFRlNl1B8Ni2RmUxHNQwRBm1AAFVt4SYtIrvNcsY
d7RY90VOJoQLmGln9JG1TDp6NioMqqjAeC1IrhFUAUVSOAKX5JBKMTKWnXE8AQyn
8grKoJPvvbj0dSqqRUMi2zzgpNorYaJ2e9TQs+SPY/215U0U8KNp9cxO3O0CAwEA
AQKCAgEAsim9UBGN2Nec5pHtdhlMtKhDvj45V2m2PaD1eDKg75nOlSKxoAJqnQO4
bOjPzXCa2PNbNQ7AgF2tt9BHIAhKdtwvY9IVmNWTnXUnScLTAF8hNhJKneT3M0kJ
unaj4X86gqifvQEOnh/RmGKPpALV+scQplAh9mLzUT0hlvUagVRyDTHgNsfSjekU
cmXR1LtyudZJp7yTjBN9enNNGp81hDtlsESp+51GCeQlqmQQ3w/IEc8QluDOdT+z
HVQNWCcmH3PZsSns1XT8NhxWcVKf2GNXMQxkxlaAn3bqf4xS0cyhKJlqelxhNfOe
t4GKj6C41U9UFMCApsHubbZeC/FLMOPHD+pjfHRb6xTSN62UbJqnvFLboCcnyJ53
o5L/ERKGBHD3jxiXxJrqEFc5UeF+D3MhZgjlbvzNiPUP8raNw/TjDYFRLZDo7ZDg
+l2SHd1Ukl+TzG2yyT6kd2BYPN/t/HzOYXmTbrOioKTlBFqcKh43AA7uQod2DyS2
Re0K9OYp4nGXJpfVcOa7C0CK6Im7HYbCZlStPV/3GqnBpFQJaItJuR9ThKeZS/Ex
vCc9PyBzbv3tLrLN27N+mZp3hhKS6GMyA4uzylBL6RvEyoVx2sxLuYI1/B6bQo4v
3LA7k3ayD1keVRDKRyKGn/k3m6x4FJ7ea6cRVAysNOzRTee9RYECggEBAPoHMeqY
nkhhglsXNXCHqVsu38V8C+N8Uaf87Vn0SZwX0cJPvYhdG/IKg9Ko297p5o3r025d
C5/jzBDWXMLv2ecgLDp6spzZVKzCbNsc81z6e4+SZ1Pjnu6Wy0KwkFxJSSu5gCvl
tK3MtEoZnEmMqKDw6VMsTbeTZ3n/JWqpwsSmawZigyrm8e5kN9AUIjjiLiAOxGww
pSckTiR1TiRIpwL2sBMLUS498ni11bQAYR6phqx8hmlrhFZNKXJylPWxx6Fxo4OK
psArdAuj6+6NQry2MnHKGuIBVicTWOzUH9i9tOwX3gVB2cDUtMmUInp2EdQFmJpX
bMPhNhwa9/W3izECggEBAPwvxQkaWmNWPT98qfKs0+LzCpRYDDehleNL7XhvoGDC
Ob8U3HqlN8TgT85XmB8BK0ZV6MHSrnrHnkZWmR0JlUUZP/3m68e8ULZ+If+u552j
PDgRY/iYn9PGWXpy/3RSokMRw3tuj6sIX4PnQEDCkaoVO5JGOBDWbNOHOOnrz0sk
NN/zUyWhiJaxKJEkTAjBZ0kvRzpZDt1fVXumhX2+uHmPzNrhAnomXI9ZHZ/ruyeb
fkWq7cGcJMoMOWqoek1j14KstMxbTg81DwaAljD40VXHifKZrYgc/2uE+KGzgsmz
w8PIQ4VzcPdJVYcH4tn2DfntdP/I5ueH2sBM9QqIxn0CggEABC9kpYGifKGtNesg
iN6sdgtF0Z9u74LgNwijzHKrXMKFT1RYXtT4J8gHRtpuu798jXmaE2nZTPbaLpn3
+YdcRWMjemMdZES7Bx1GBzDn3fGPaerQcfYIbgP2KQqdj/3mDKZRP+rbaGFZzze4
hv6kv/ToYu0F7AG6pK8hqDRpPzNt7TBu86Pj/tKMoJ4FqKAYl47HuOvjh9Eywad5
BGB28zS/48G3vSdqTJz2k8nB1mqOB4saEN+s2mj2PaUvWyF7rvcg/o2ult7jVWKM
C3Uv3crK816nrorJL2RCg8xVMCKUybLok3vzsiedUxZ4sUYSrFLfqA24k1rMthG5
ftJwsQKCAQEAicQm5ZQp8L558ybNSK81iXOwQd3fvrxdP7CI6BRDDtjL5yEkWTPM
xZaswlKD3dwrod7oqonHm3dVdaN1PbGwg/EJTlFKWPD9PtSlCiKokStNiGunq3Tl
SzG+S/BqsUc7MVyQ5+s8PPj0BQDdzwL7xGiZBI2rrzcUeHIUm2Wg9rGu2PD6aUJX
dcsOGEw15UqSfB6B0NQ6FKEx97y+jDUWXgI6rQ/i5Iv0YLMURfrnYPnG/5QjEnOU
fXQ0IZosRf7XCqICmuj+ObyImsrAQbyLz0qUh52AeS0uM7SOhvej6UB1H41VpZ+t
BMphGMUsHloWxIP+OIWt7qn+zLK94qVZmQKCAQEAx+B8fN7HgAJUlCEGsxl7ENbV
DlL8gcHWe6xsJiFE2WyREgpcaMjeSrb3UWTO+0sltI8miTlATdcqWDLeerAY+QuL
NbhndQ/ZeGXTe72DIfLK69375R+q34Pk1+FglBF0vp8HvunYiLc8rfNBs8OTRqK+
tizVUv8GtLsVXjHfignMfCtdp605y6JCaXJGGpF/UJOjzGDddy27n3ngEScMrqdH
i9VikVfjcUy34M/ix28LTj5NewJSiRQw1IM1TVBfm4ImnflRSRgMwF3oqnQB6n5y
SGpdYXw0WJUS/1dal/Q/J4TIZ+Kq2xO1TWmt0jKrYj8HJy4jy3gSHvwyKhJgrA==
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
  name           = "acctest-kce-230728025105660632"
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
  name       = "acctest-fc-230728025105660632"
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
