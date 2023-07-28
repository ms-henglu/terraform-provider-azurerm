
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025050764371"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025050764371"
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
  name                = "acctestpip-230728025050764371"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025050764371"
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
  name                            = "acctestVM-230728025050764371"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8020!"
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
  name                         = "acctest-akcc-230728025050764371"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvI1pIKWJAuMXcDZ4L0hGl3t/RlBTAmf5uHO54gR4ncKewvEKgmnH5MWvusYvAMDV6xPnrhCIpIc55GK8WiRmbT4ssSJvAXaVTCJW2wpmrjOAZ6o+0dwG3P2VtW3MgIFDk5DlgrRK9NLYOtlPKzhjbc/hBBA1aQQZOEzByZpUtvtzPl7mdL0d+3MSCOScTl2vsMw665J6CzAh96m7oAIpYI9criC0FuWKxbPClMuTto0hN3fnH4QSPwa621HpH2mIe3S4cqWgqq7/Q8fYmGvDaE8++qofriqkCFi2+fNXbjZis7marzYclzNeSZ7a5XwsZ+3agcKTM7cOJZMooXIlKbqfLyFUoos5v645Kusk80NhU33Dd/djvfjb492uQ1M9izq35ZsfTj3ju3WsNtMqdjb8/TPxkPaFBPhonWlG461TfpdZq/8XXhmpKqxOYPfAmjM21nVQaoEdEekB49It34krZYXagzY+hBeTlu1uBdoqhegpc93hLGQq6Hhr4zX6OVxk3JputOv/RSDbtlnnmAEE/5Vhrsn2vBJsHpqcTKRpTGgLm30dgJ3PLG039a3Yl4iVX0EENPtt8j3Hv6tiExS2EuHEQqdX6MEnbDdI7DViep7QYjrqlfeOjgjYDc5kZVaELEDrSOJcdftbUtCTcg9YQ/SeAq8y9ymMt8/TumECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8020!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025050764371"
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
MIIJKAIBAAKCAgEAvI1pIKWJAuMXcDZ4L0hGl3t/RlBTAmf5uHO54gR4ncKewvEK
gmnH5MWvusYvAMDV6xPnrhCIpIc55GK8WiRmbT4ssSJvAXaVTCJW2wpmrjOAZ6o+
0dwG3P2VtW3MgIFDk5DlgrRK9NLYOtlPKzhjbc/hBBA1aQQZOEzByZpUtvtzPl7m
dL0d+3MSCOScTl2vsMw665J6CzAh96m7oAIpYI9criC0FuWKxbPClMuTto0hN3fn
H4QSPwa621HpH2mIe3S4cqWgqq7/Q8fYmGvDaE8++qofriqkCFi2+fNXbjZis7ma
rzYclzNeSZ7a5XwsZ+3agcKTM7cOJZMooXIlKbqfLyFUoos5v645Kusk80NhU33D
d/djvfjb492uQ1M9izq35ZsfTj3ju3WsNtMqdjb8/TPxkPaFBPhonWlG461TfpdZ
q/8XXhmpKqxOYPfAmjM21nVQaoEdEekB49It34krZYXagzY+hBeTlu1uBdoqhegp
c93hLGQq6Hhr4zX6OVxk3JputOv/RSDbtlnnmAEE/5Vhrsn2vBJsHpqcTKRpTGgL
m30dgJ3PLG039a3Yl4iVX0EENPtt8j3Hv6tiExS2EuHEQqdX6MEnbDdI7DViep7Q
YjrqlfeOjgjYDc5kZVaELEDrSOJcdftbUtCTcg9YQ/SeAq8y9ymMt8/TumECAwEA
AQKCAgEApDWzvM7tyCnmm7+UY/laIUtYyO/jm1DaVx3SYVjrgtmgUr6CHJnrkP3p
0YwQG2PV6eln+FxF5KQwcwraZtcUrUdcvNf0PR39YFT3t8QTMNuBlMbb9wDcqVHg
NCXv2Gq7Y6TpfS9vqFCIKJhhLo7paRWGLne/TDpZjIKssttJtCLBdyxHIJwjpH3O
0xfmWQmWnS8AkXD8AQpmSr7zvKKlTocMfEnXDanTdeLcL6IsfuviZeBy1Su8iE9g
JOntUYIjbwF0McS1bHEDtxAxPm17vThm7P+En7ZbLTm2AXFAT6flxgh7AuTpeXUv
RIaotPuz4L9xcVj3wi5Gj8rds90pJvO8FAb7O4hm7pny4HPurpTyo22fZBGR29E8
o4ETVwxFYnoQKwvzf/SBoYRQKX/wLATI3IHXmVCNTcFrH2kjPYFE0uGH/UqdiKEr
VjC7MjKITXAOeO+QTTPH1rliNqQm9dL5BM7zTYZEZy9yU38Ffl1bTxbmyOD6azA9
GA5LaIZsZB1F+2p2nGg7+ClNpCG1k4nx5g6yfDdkGKnN2DFT8m4C+EGaTCPHexol
/mWyhwSXHmWcTj+k/Wy8xBv3SHbj7JyZf32mIIO8UrU0iGYKg42qdtFz0lxFSpaR
BGu3SgeuMU2MH8U+C4aLM6Gb2DKZrCcwLZZrItT6KyV9qzFm3RECggEBAN7bA7Yk
hc/we0khOdTzTBK5KrMY1opi7scvKzGF4c1/l6WsNMQiTOuENE4mS3kEz5udwOF9
VMhFJFNjTIJvAgfPp+7OaZjaYU3EGNy1YJiTb1u5f3USgEiEFIzqniGipxPjPYUA
tYamA3uUs8ztyRJw10tb3M7xLxCyuKmDG9wzIduPkAdc50MQ1HUiHnN8BddQKaeV
YLSpfLyjwWfp80lQwVByperVNhSZOjNzvypZGrL7ihPTV1ASZ44AzhQrx09NgsNo
gsn48+3iTlh7+VOPnSncsaM9XfzfnwXa0JI0OUtu2L00RaVqdGcHRiuVNbpMVbKh
wI2q69VQFJTHYmsCggEBANiYV0C0/WiDaxuL+SpdDxsfSSyKOLfFxvsq/Jt6USBI
pBaRWJ+X0YJN6zPb5wKNOW6D/a2O09E2t56KReKB8z6PJAJlxJp4P/3FWk9nLyLd
lMy1HSsB8+QSrBThAChdUZEdEB++o3/mYLFpERXyerxOrhUSMok59aKo5S0sdRnZ
j0UUjlODclhtsZyJ74bb26a/p3DtJFN725xMJk1kahqcE5Ws4kaJh5T1CIJ+vgIL
TmrykcpW5WBRi3kGIUSgwpLy7Gku2fXkeu1lPebA2XDk4CqTHUK6RFLB5tz5OwPa
OvQTmRVjOYr1XovF10uDU9lXjGn0ZQH8lp/av54SwWMCggEAOu7qLVm9NT8gKzep
JoJshKsI+rG/0nrVMEFuB7ui+gga30oJ7jAv7TxZ5KzF2qwGBt4R6s+NAyUdtRuW
WQvoGo60lzdov25Iuxr3hC5G7DJZCYWlih0pZYPgN1+4D6cGzgCS/UAxwPjYBO9P
GQts1/6VQK17WBJ54s2QfetZC8NN2dU+PmQ4GAk0VgF+0gVjOgxN565eE4ianvwj
IkrA9otvg8m9zLszgQEAXijmzdkgcWKJojKKbXdggTH/TWBCZdtWkDxsEeNPBoKJ
O2cViR56bl6Zb1TELSIp2I+EBpXe7O7UTDytik/7ll9bFB1yRuD27LVPyWcA1LlH
qAyOHwKCAQBOyUNbzzoqbTtlvsm4xjb7d6rnX7P37SJPNLjEWX7vDl1ZtC8XhmL4
Uh2PNJtYS0Sr1alOG5kjDhNGwSdgmEKB7BF+KcSVJ86nIcWTAoab2RwKRotAnKo5
uS0NPzcOd7t23KqD0ZWprYRYpE5JvHU20Cv0kDT/w6x9KZCLmRNTftblmu+Wo0bR
sb0covQVCx5gDnD629gN4gzlUrHQDwmlekaJeGSqodZGsccRqMa2+aPhtTCg+HDh
U2g3cqphS1TbnS+vpxIzppOsjNoyeM3fifGcqvzGy/iUXeH7WVFFOnmdVQ+nPvus
d0qX7zQ8TJ4Qfg8eb37adSXZKfnvpwTfAoIBAFdN+L3PFuSLTLJcb03Zgi8zJFnu
eOpMptwtwYsd0vGly6WiTP8NjpEYDs5STcUWxHoj5Ds+DDv9wSF4SLlbJwy0+kIy
HH7KCrRiqHV4EDOX/vzlyaLyH1sR48TVG3YH+CBCFvUkjCoS1TyTCWtv8oY0hc3I
PSQyxAq2MzWNx+hDZRvlB7c4D/yQfFC4xpintx3vAAaClIZg0TjnsuprM+vcBoiq
KweJjhFOhde/OKWYID59uElWed6nLufBdYZQyroelYMxXzTHI83XAuEe/uaZh0+V
F6Rxk44dv5Ucdhd//siB0Wjur3Js9wQPXzJmAkejTetBhVg83B4N0p/G9nM=
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
