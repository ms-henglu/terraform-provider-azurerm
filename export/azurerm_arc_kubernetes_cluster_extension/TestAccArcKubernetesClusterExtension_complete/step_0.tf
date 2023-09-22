
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060547603352"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060547603352"
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
  name                = "acctestpip-230922060547603352"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060547603352"
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
  name                            = "acctestVM-230922060547603352"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3821!"
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
  name                         = "acctest-akcc-230922060547603352"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsdPfMnfGDsY7Zu4Sjz912RuUMn3ZMJ7B1zzsGpoEm6mWUS8qZ6Rzdsu4Qlll7EQ4Syi/v8IpCDW5GuuC0vHihYhMlr1ckgZCP3YmVsxRN6DI6dJyzPPcpJm1l9C+8RDE+S6ofotz+LEcWsBuKm/StCGPdXt0/yl+nJ1QXoG3mGZGyemsR6LJSpFvYUEcXsLqLt7jnhdu5g4olkfqdJneQ4K7cl5sVzdhtOz0LkQ5/Dnqdc3TBPR8uaOaBwk1Er5pHMkLhEeSnLJDXQE9l9e71Ht4vRaC+Skn15oKGOPoSg+dcip5w41HK9uDH0XUNxpNTW8gGikEq0IiLJs+cc4K5bZ9J90akhVD8bQTjIsOXcl9YUYTZC1FgBj8G4usScRqpmMiohGLpM2YbVvFHMyqVJ9cBJret3itk0h6+hagu18ClSdqmIbGyZp0Eh+l2m/RijjcPYBaKZnOHzpx38EY+L2CAslooaLGYyTs5gHykekRPY4SLm8ER9MGadgM44Qwn4FCNa+a+kV2KuPeUGkFeGe22elsLoDX8X5Jhm6XB+rQrWj6y3Q43yaw23s5wDrDCIHks7NCtPn5biWLK2cOOsTfXRMGCoxMpH3Lw1w/aBfz9we7ln6rN9tcWetp/NtQCGrD3NfhGp8lZhNgwKYKHx61Is+TZtjXod5nF9hGTEkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3821!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060547603352"
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
MIIJKQIBAAKCAgEAsdPfMnfGDsY7Zu4Sjz912RuUMn3ZMJ7B1zzsGpoEm6mWUS8q
Z6Rzdsu4Qlll7EQ4Syi/v8IpCDW5GuuC0vHihYhMlr1ckgZCP3YmVsxRN6DI6dJy
zPPcpJm1l9C+8RDE+S6ofotz+LEcWsBuKm/StCGPdXt0/yl+nJ1QXoG3mGZGyems
R6LJSpFvYUEcXsLqLt7jnhdu5g4olkfqdJneQ4K7cl5sVzdhtOz0LkQ5/Dnqdc3T
BPR8uaOaBwk1Er5pHMkLhEeSnLJDXQE9l9e71Ht4vRaC+Skn15oKGOPoSg+dcip5
w41HK9uDH0XUNxpNTW8gGikEq0IiLJs+cc4K5bZ9J90akhVD8bQTjIsOXcl9YUYT
ZC1FgBj8G4usScRqpmMiohGLpM2YbVvFHMyqVJ9cBJret3itk0h6+hagu18ClSdq
mIbGyZp0Eh+l2m/RijjcPYBaKZnOHzpx38EY+L2CAslooaLGYyTs5gHykekRPY4S
Lm8ER9MGadgM44Qwn4FCNa+a+kV2KuPeUGkFeGe22elsLoDX8X5Jhm6XB+rQrWj6
y3Q43yaw23s5wDrDCIHks7NCtPn5biWLK2cOOsTfXRMGCoxMpH3Lw1w/aBfz9we7
ln6rN9tcWetp/NtQCGrD3NfhGp8lZhNgwKYKHx61Is+TZtjXod5nF9hGTEkCAwEA
AQKCAgB3Th+D24m8pdB6uSUoiDoHpBIkYfySOyDvyAbbvhNzYC7iXtODX3i77ee8
VAAmqIpgGoGzJI+k225KGlHWNsR0NEK2K2ts6NgPfbQxLbkbqjrBbRjqWn3gzONh
bIJ+d3K/f0c6R1NSOXk9hbcjr4xcn9uAxYh0HKG+b2jZTwwfKhc6JhUYpqWH6tUg
Ga/v/7NgKNfrW+tiW4Ntd+hbvFO7VX1vONxVE2nxGbylQc7pYu3jhWia/XCkl5ei
OtIptigNUPDyGZbKnGrHfiqVsf5pi0ExE2ZhxfPeGZHGqzlQXvOSAd9ZjHKAgTCS
jaXYJkRQvEp8YqKoR6Fn7evSLJtv7jw6M/ZRdBU/kSscqKoT62vP1cWkHeNWHNoo
72J/5DsVv+BY65LEWAkFTPJeQNmD8JZCho86Ngo7IfYgKOLXs+Es3jKk9QbYHMAh
sleycf0zCWVDUFY07sUpFQWxbXi5ZLdo57DvShtvHkqUXgEKQJF5ZavtkdKmaW4y
Vik+d/xxqqUhkSdLF+EHqeAoTa1acMpT5P7eul3t8LARWlI7u0esvTVeFBK78X4B
YXuHX+mflgv3ZckbgZjDGfhLc8hWZfBDGHGJowoDPIARqn/dmL7yugo+QaaFStfY
ofBkTKPFtbCkV+Fsh/lZpn5jm95JoYMhzNb1x3aqDFctQQDNgQKCAQEA21oYOHGF
UNeQUBzMKdGiQ0fBYxxEK2JHZ7l2Q5x7ICD6hBTsV50GYUUOx6U6DmCVIvOHgnCu
sCn2yL8MY66VTh4BWWlLMQQtM+avk6WePXmxQUXd55fAtJcCuZuxQBy3gKa2HMou
nHEdYYW1Tv2mO6KGumGbnEdP5YoEQnazlAmleQUm8JtT6M6mti5nY5pNg6YaXeWR
3tEsfK6HZ1s73MjyyCyakUx+H2tTiF9qBJVWv6Gl6+i4l4CsDL5TYQKTdeT6d4rl
mGl77Pg9Sfevo7gOrBFao30xy9i0/6z/ITdhQId0hG8KD34BREEI1i5t9MHgTga5
iazzYrhoRrvNeQKCAQEAz4m9h8pZ1aLBvDbPK3PXxWT7RQ5wJ2Li/MAfdvsi8Ddg
vCX9bxseeUouD8wwcL+NLkuUkmn3Qy/iyNHZRL9dAbWF7BX54tjQ+mngyGqdhhZO
UVAYJeH6ApaRjC4FE8yYKuzWo3edYy7DOrKXPlh8anjT4pTMwaGJz3N3f1YagUL0
bL/w+Z+/5EKtUbvkNoIfxnpZTEqXbqcRH4soy4jHbc3s3otX+YPRB8XKdyQ6a1d+
1sy7FJfCNEyn+U4dEdNCAsQvctrzFlh8ziyEL//0WaJ4Ykv2pzMhUYPMdJXG0pcZ
bLN8E/L3uJFY0+XffsEdwaa2YCAMColxLKk4ls9RUQKCAQBsB+pH2jkTgKc1nYk7
y2BEDJIFEwXL7CJIxoGleOr2/ucCqB9iYxaiT1WhJBH8xLqOtSv3JTIT1wcRBW6/
pVspVwPJGl+K64iruCCe8gGGO2n+QL+ycP3as0kHStO4RKxnszOb6EOejuMuhaCv
H6OAWWJLZwkxpbmGzjuc1ENLVJjnio8MDyP7U9OthBstZfBpNyRjPE5kU9a6LWbI
k5le+qT/y1/w0aCILt68Gmnniflodd922W4YR6n0uMPt0kv302c7+u9q6gC7y+K7
jD43vs2TFxTx0hX1VGyIQ5Z/sHu4QT40f0+QI7nR+Mm2WrWSxu2G4C7+zGwuIa5R
r+rZAoIBAQC12kobPHIvQqhkFdq+holhTDTos9gOixW+x1JK3ZAl0UCQXPGPc8Hm
Idvut8sSYKaDFHMhQH0LgGBF+6tYFB6ZKsgosLD/12B2rGPs+Y8COXVyxq4CM9rw
faMXpBOK39HOey0wm9VrXURwoKDqXnrWiP2RIzWvza6F+vWQvJAJB/RJfn7XHOX2
S363id5U7PyO3BJ3ST0cFoRokXWzsyycyL5v2sXBu4FkQCpC75nJCSf5a/fZ+YiQ
b0MYrxvFzMmgxuuUxsoOoIbr2hISRUOFb1nxOALvS1w8ozJ6TeukCAadO0DT8iii
r6mYM2r9FJbQYxaXcD1c1kY3Diip7QuhAoIBAQCaAP9uvfYykd3V500oZ5O9So+f
yajL1AFbuebKcltQEsGqszRV5coFuRKpw5rBR667tHd352nBWjPqmjyB2OGdJOrx
upsxcXZhQ0+QBuSMhn/AI0UaixPMV2pzKeujKI4AB9ZVs29Y6u+A150DOEW/qojD
JBVgGYyPdDEipJkios3PmpwOvs/KHiM2ZObSAQyYwOwVyIrhVQzganGuEUWVx/AP
l/vemJtKNzRRsCZPfTjM34TlA4QfPDo/8dTAXMBWsR4GvnXK2HSYYB+kPfvav1Dy
yA7gHrUwC+ZTU6r7HhUTq+10BeCzjhoKayiQdQNQdfYG4bsqJXotcz5/XmLo
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
  name              = "acctest-kce-230922060547603352"
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
