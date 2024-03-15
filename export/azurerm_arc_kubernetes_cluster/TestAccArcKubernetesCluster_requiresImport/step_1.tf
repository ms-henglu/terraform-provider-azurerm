
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122313313044"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122313313044"
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
  name                = "acctestpip-240315122313313044"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122313313044"
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
  name                            = "acctestVM-240315122313313044"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1825!"
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
  name                         = "acctest-akcc-240315122313313044"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzdl8MpqxlKhuCQNUwuJ6mdK60WNOoZnUPAAtWDGat5F98GSN8Ncs7rfWhChpc5en3x4SZ42AMLS+UOj9YS84HJzEdPot/iOoljbHrem50piN2vL1gNcYu13WBHSBYaiZLg/y5bBWosqd38+XEcJVtN/T6AsMknoDU/mKFbppBS7CW2WYWZRiKcI2xaJN594s0i09Xc/gUjSIORiBenxj80tSH8GI1FmCaSyGElBUJFfD66D+WYS8i6fPI9Xc7SVy7S4x10Lncvw/I2yuGkYLUXnT/cQnxre7BnK+fuF+nZ18l/vvroVBvN/JhxDeLszKFEeGqcFk7oxKXfAZ12MDRqTK4DB4qFMswab8FSsd1pg1E4pFGGYD06t51ohcUY0UPe/69aJWBd7+bD2u32p92wMKE2jz6O1paOwzDsrd/H0CxZSd178WC+YKq4gR7URRQt20WDNaCUppN6QSQE3nrxtmM6INAbZ8uKWQuDVKNTZ9EqE6H87FFKeUhJVq0rHQf0Ra2/rBcimZzO5+38y/es54inOfYmXcl08HxRZV/jdDgX2ZBJy/D4ZiVgkg3ZzOc5c0/PO4k2+vDIJPkUt+rR54hXZqKwO9UMQULQ1zd0FTm/0ksP+nkRvUwoEglCbz0+7lqzb8DqCeWRue1H5p5E7uIdJjv1jDz1xQSgyNAWsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1825!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122313313044"
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
MIIJKQIBAAKCAgEAzdl8MpqxlKhuCQNUwuJ6mdK60WNOoZnUPAAtWDGat5F98GSN
8Ncs7rfWhChpc5en3x4SZ42AMLS+UOj9YS84HJzEdPot/iOoljbHrem50piN2vL1
gNcYu13WBHSBYaiZLg/y5bBWosqd38+XEcJVtN/T6AsMknoDU/mKFbppBS7CW2WY
WZRiKcI2xaJN594s0i09Xc/gUjSIORiBenxj80tSH8GI1FmCaSyGElBUJFfD66D+
WYS8i6fPI9Xc7SVy7S4x10Lncvw/I2yuGkYLUXnT/cQnxre7BnK+fuF+nZ18l/vv
roVBvN/JhxDeLszKFEeGqcFk7oxKXfAZ12MDRqTK4DB4qFMswab8FSsd1pg1E4pF
GGYD06t51ohcUY0UPe/69aJWBd7+bD2u32p92wMKE2jz6O1paOwzDsrd/H0CxZSd
178WC+YKq4gR7URRQt20WDNaCUppN6QSQE3nrxtmM6INAbZ8uKWQuDVKNTZ9EqE6
H87FFKeUhJVq0rHQf0Ra2/rBcimZzO5+38y/es54inOfYmXcl08HxRZV/jdDgX2Z
BJy/D4ZiVgkg3ZzOc5c0/PO4k2+vDIJPkUt+rR54hXZqKwO9UMQULQ1zd0FTm/0k
sP+nkRvUwoEglCbz0+7lqzb8DqCeWRue1H5p5E7uIdJjv1jDz1xQSgyNAWsCAwEA
AQKCAgEAywXObaaOsHyyEeecKJ3wp1fkc3GLcuziGs9d6Zb67kPrvzWdnMTMhyD/
zNaCssQHiJIDOuifXupUrj4s8TX+FJI1XN4GkJmgw46BwDA92swlVKW9pvX+aYVx
+HDjzmrXsUt/mDQkLmjB7qSybYyKtVrwh/Kl0q3OLHt4SlfRDpCAll4MNYWYj3EC
Tkf2qFJDSIPf+29z4f/3vsBBq4mVlrZZ6AIcLrudWJfWH6fkZPe+vt3JHodA4kh+
jux1+dquj+i4tYNB/PF2YDznNfiRXylWAPn+9QnuxrxSz5cdJtzVrpyHV0wMevkI
rVLgn63RPNESqsiYAIKTMjUFd54q8jOy6Iu5SXMzS3bzl0GLwtxQu5zT+wvov8NZ
Chku/hIzP5j9F3b/Z92BJtZuyY6nkOldG7JoaLivF/mV7GZZaiiqSiGyjENlHOtC
Fcbt7ahNam299I/FdxNmG+xJVH4BPViNNLdttUDztcRDiz4mfxRGyfrcC1TPj7kC
DAfFzbmsic/rDUCkVe5WoH+v2CJiHUdHkdA+DlxKs94VAFqkqbRvwbPLkvUglByH
uk+VhBa7bQ6HfSqtqo/UzrjBsBqxDt2Ioo/sM4rse5YyPWdz/j6HlKJvRJTtIhsW
Cb/pVVocZD+g1bBUEOf9T8ij5RQQHPsVElVHHgaO2kvo68d3KAkCggEBAN4drdm3
DWD5sl9YXCDaiUtJmAGxxYIkH/08G9Nv5GOgY+1pdWQgOQ78j7eR5cLSuRZMTtPH
58gk9ZYJq+A07Zc/g1H+MGY/S2W+xLah4sIiR2lUIr/kgkHecYJcYPSlIm5RceJ2
B7RqCKoxrgSUSJWyl9TqWM9JLXxG2j8na2Pk2gy19MtjHQvQi9lvwUzpTX2ftHFT
lxjMIT0wd7JqayyxRFPoswZXtU1oA6qVXzXm3mMfZIx+hFa1nZ2M/BfuIOMwAvCh
y/Nv3mdROit7NTZc8PTuoDdtAf0cN+ubOHobqyGb7kqvNbUbGRfrWWj0wBGZFOQ/
CCzj8LEV586v9V0CggEBAO1AjZF/DQ1r6ULh9mabkuEvjqoyzhGNULCD6bnRhnAF
WSfUqqgQqYgzryUr6yRCig5+Ro4VADv5YAiydEZYNnuyVgkU5yHkay5N9wdZqVSx
J9sktzl10ztDtkKUCsRmDwYIlLjV1Q6m5bwpwpSKw9XDo4SpIptVTxq5rZvvPDsu
k8bxQyqwT20hVIsWQb5gjZeMRQlhzwG62D/V9DghyREyCjMrVdWdzTGdoQRsLsYG
GZUBaNH2DASpvHec4O8jFkd505z+HVRWVxVJHnNGIM22wGlGBMnqxebhTOHkeGtX
Yzt1i3Fga2rqb5ncHhHcUYYpwn1hRYYZ12TrQrGw3WcCggEBAMFcuwUmq3n5xkPk
q0damF03cyI+fX/fLQ4KrvqxlPT6IyQCQ9TnjGS0j/SyCYBCbCiyQ4lwpSICst1s
C/nCeffKrerKS54nid7IZX3MjpiMuPhD64B8UL1BBjYDb9Bqlf/N3UPVlr2D9Ykc
eK653Dqd4DnVzXye6v8eu05xZbbv+rdIDBSncxje83BWLsRi8jfjuXVS3N4Ujvcy
43Ep3aVpqN8XXAqwfkAlxdNR+DH3izBlmuYIGfNWZiFLJAc9IdpF6LlNUTza7ZWq
C+bgeqGZ5ZaEymuV9T5Au5nbZh4/SgqXMapIv4urTHwbQZnyP+bSCnLtQJO718SC
Gmw/mG0CggEASilxl1eFtvpScgu8QBrFcQqyp9U1wRrRbDvv5ZvvUDj7w42gwuRi
eibdytrNqAn8qccjOuqpphWvxUgzPIH6lfQLHM+h6GBEeLb6Txvh6I1wDfqOI7IH
E3F5GZq5OudELvijtJty/B+DlKvhHRm7WajMBn3wSWoDTjFYaXQA+eb3Xqqv+joe
udg/WzLb3izEVekM83/Ve47yZhH1Q06cUXm44oHbVOj86VOCr6U5gcEKYh+MqoUl
AJgmR6WMUnQ/VJxqX5q3hFNw6UBv+kyjmGpV/xJaENwIfMFUjRAj7Dnm1QFLU2d2
bHdX51p9M8wQ18VZ/GNZni+ZuvwnXvAQZQKCAQBHQF60wK05wboL9aCMe0fM3ELt
5ovB7vcvaPIOzZD9OSWQU65g1S7VbPdRMnIHacwtNPdhmLrGR1HbE/KGO+c/r0+H
wFxku11uLLCQd4mKfSGU1UiKdrdTAoA9UE4QG5vhlW6qe/LWvHgdQbyuLhY9/fuc
GWmHr9OeC5OT5SmpLjwiIv4WNj2e7fn1BwhMbKgqNBnThXX7zlwz6nRkTT/2v+3/
vnl7p2pdAhQXvRU4i8YGpoOJp5VH62PoW2H+mz0ugsRWI5apk4VfcQiup6w7KOSp
7TvO6CCTSIZfTYMQJOCv2n8+rkfHJ+p6O1S53tRxIy2FbCRIiQjqaBao30kT
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
