
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010002345312"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707010002345312"
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
  name                = "acctestpip-230707010002345312"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707010002345312"
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
  name                            = "acctestVM-230707010002345312"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5242!"
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
  name                         = "acctest-akcc-230707010002345312"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyh/dQyil5QVJUDrrMiWE4pvMMvgT0/kvIwfy+gWTtPbVGlVqxiUV6lipiUHNEckfkRgkVvsQcMOdBdIg3xdGq9qJbZdr5rNBwREhxDhsM3MfrAoWiICK6YhMBAwviJcxn5BfyvhDrrWC8dnVSeS770MoSHKJA/2bfm0iPU/dtGVVbeX3PRWMQPFAKVOznVtk2bfZZ0Q9hFWaUZqfPtJpib9Dp39XJNJ2xsmJ8vz1GZsTle7ZdRkNJskiDxqgQAXLHCBzm/L0huMkW77ICjopIlavIIujQ8y9i0QqKdy5GUj2ekEAcCAk7D0RuqdrJNp75DE4XW499R6o1TnSzNla8geMk8xYasSUQSezqCknqbKV4+r6dYoNCTBI4gMalrmVNVyBGwavDFMh21eeXyTdOw1tZTjWNVT1mQrDxvlGMJ1kb2T+BGnhlb29coMyIMkX7l2gDh6CY8oeSV6NmmZARXNAaPaP9ldk+wEtyIHYwHfMQ/9ruHRKJvI7d+hAyC5axcLOOOCcvWKCLmqNz/61vskYkmNkwQ+ekeQ8yYfYOEjktElcduIc+GUtC9cAlYDnHwvSo1bqy6+c8q1ReaXhuYBxfwidNIE1pawnUR0WIvGFqMP0TA3eH2e7AXN+nrTXW2FJWraOj4B07QEu/2XspHJa6GVjcADKE3pjPvHjT7ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5242!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707010002345312"
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
MIIJKAIBAAKCAgEAyh/dQyil5QVJUDrrMiWE4pvMMvgT0/kvIwfy+gWTtPbVGlVq
xiUV6lipiUHNEckfkRgkVvsQcMOdBdIg3xdGq9qJbZdr5rNBwREhxDhsM3MfrAoW
iICK6YhMBAwviJcxn5BfyvhDrrWC8dnVSeS770MoSHKJA/2bfm0iPU/dtGVVbeX3
PRWMQPFAKVOznVtk2bfZZ0Q9hFWaUZqfPtJpib9Dp39XJNJ2xsmJ8vz1GZsTle7Z
dRkNJskiDxqgQAXLHCBzm/L0huMkW77ICjopIlavIIujQ8y9i0QqKdy5GUj2ekEA
cCAk7D0RuqdrJNp75DE4XW499R6o1TnSzNla8geMk8xYasSUQSezqCknqbKV4+r6
dYoNCTBI4gMalrmVNVyBGwavDFMh21eeXyTdOw1tZTjWNVT1mQrDxvlGMJ1kb2T+
BGnhlb29coMyIMkX7l2gDh6CY8oeSV6NmmZARXNAaPaP9ldk+wEtyIHYwHfMQ/9r
uHRKJvI7d+hAyC5axcLOOOCcvWKCLmqNz/61vskYkmNkwQ+ekeQ8yYfYOEjktElc
duIc+GUtC9cAlYDnHwvSo1bqy6+c8q1ReaXhuYBxfwidNIE1pawnUR0WIvGFqMP0
TA3eH2e7AXN+nrTXW2FJWraOj4B07QEu/2XspHJa6GVjcADKE3pjPvHjT7ECAwEA
AQKCAgEAikFZe8KmFw2SpEpo7pgzWT3wYzzFc00TLQcW8GY4LqRYB/c9XeOoJfAX
p0dXGj9UVE8LLGP3Tuq+0Wh2C6NEN/D35/qXV+pto74wNqPRfy/UDj2oRB6I5kzQ
kkQzj168FsUOgStoQGzv8LZr6muHEZYCS+vsRMqIPeYwcXfb0rUtxkpy31mJ4jIj
DSGvzobhaPsUvkozOf3D3OXC35nVjt9BS6US2qELldXtgkP881LcBsamAC7ujAUw
QtyXmLNdxxN7gMSi9lEQYaER+8zkrhRVHhHlz06QqF4r6Q6NnfoGfoFP52JVXzI2
mlJCO6cm72Orhl0ODEi4e4Fd67kRNxyVTxSTpQ+a0OLU5SOC2Pa4DO7GyW3uwZNv
Nx+9RRupg/TPA33/Y73S4x+Z03Lxli50ChLpLbfwu6uQuzLFR9xSUluCI1I32jdV
94FuvqiqBP+07b3U4ConOcfAZHCuEc+BER5tZBJocGbGu641YYtFDf99psd7n6b8
euh1dOMMB6XYxlVgamjVtGg6x5Vl1IssAf9mLTVvwQBDVLZII44Vw+7VQTpVY2Cp
cAQ+yV6Q2CZkhJY6syWDOH4zpA4fOD9H8RQ9sVr9+euv4e4znvsJSr+82udrOB5n
uuy9adQxBcj+KkNa85bTXLl8jrTHD/DitWDcR0Uyi5R1UZVRxEECggEBAPKOrzfS
VRhawAOpJT+s7BdcspGOmxeczNBPck4pdsss7m93ipIIpUmLRJP3WbT6g1i9wx9d
u0wJ/+R6K1rPwHY2NX//uSbPTOHjip//OZKoWeBYuLZp8Px+/gXYfGxUT/XRgSq8
amwizRbbeOMMbUtGbjfOWaa0ztsCuo3tFNJhmfxwu89F+GjIKSKOgwiQOTQit5SY
rsVHqd7I54v2tHGrBzDL16aSTHdXLzga3+3uCZYoVcR1q3eo9pPDpVAGmwQc5h+P
jAeukY1iPB076IvoI5iYFyTCxokyG3/MEYTqRKk2tZ7ht6uySZjQKzOkSI/1CL+H
TFvPDAoCJ5RnWw0CggEBANVTiGAnANgm9AfvJVKOhRWKicfeP8v1Y8Qudn9CR9Ua
9MULnlDFL0s/GGf6hHBh2sT12WKeJBf1sm9WM4y73YnTkgMHZGMaElCN6gnEgMnh
97V74wRB2eYLdKb6Qug0Q+aKJ0eHa3u2wNhZYNaklGjQKJT/N1jR3BuJxnwQVE6m
lCIZh61olo047bJEVTTu/BuX06lPnrsEkRTNGfZqpzBT6Tzg2IZcJ1w1HNhgdSZG
I+C514zXnc6z1J6FhktIqPHg9vQSFJvjG3dSQ7lZuvEAPKMsW893CoJLzw+KfkjU
11dm8HcbEOHmpCgbKs8WvXgp2jyRU/6PV+Wx8X/dzjUCggEAD5ipH5fArP441oNr
x7pgu+fT+5QF2PDWIpbZLLlx0AKlmjk/icBQkHgKAtGmzQJGq9AX2c53Gp6R+6j3
XLF7GJ7HteFFkH9H3EZ7RWpt00ZL8ScDSYdqXXH0939CEN0i/xVnjs3qseVS9qNK
FJ9Z77spnyD/lr6NhnuYb0PNUPHBqv+8s8k1/dbQ/k3Xkxdi9j09PKrMohbHj3Gv
ocpNM/nhTnvs8+L4U7whZyQjPfNOXn9ddHJ0gg81O68a1Bh4oz0QdvsN7/iDl2m3
n9GYVFaq40b0RgLYLT4xkngWsEs3+wFvkDXHT5z5KoBIJtvrZoZE97vFZynbBlG5
Jcu3iQKCAQB8s3XW7zXZJPwl3y/sEI/PRcrA4TRd37ZQKfDu9ynScw1+WgpToNDC
pcF4lsLwhuNBm41Vzqe+sct6teMwc2lPdjO2PY37OHRYTnzu9MVsPgF1P1Q3Wt8r
UKsCKO0Pm+3NSBkqAQldqjkUvzqSfmaa1oPChWYvL44BMwqp30nJKCsTu+TKA4du
Skb4nGVKqiEJaDk8keRx4nuEs1hn6XSOFZ8UDUPFVv1TM2EHQ2t30iyK41gTZr9C
43B4sgkM3Q6VRjJV/nO5pIqbt6ULJl7XHpJTuEx6/FVSUUpbBVRI8tJmrzAGD/ZQ
d2iiYS8nG13qbly6ZyG4fsac6OYJHvm5AoIBAH42+B2QL8GKmyh/3zD5p/4TU4X+
qGc6YUqem83YGkJWshthkXtEfzlgjSXUkl5odExAFW3K96aEu6K6M0sMSdoAQLcF
F1uVPWiRyTLsdzRi2D+kqO5t5Ab2yaxedDhE5fBTM3zWbI6eTiUHQw7PxkhtotWe
zgaqev4+2PhPNAYxUZRGNE2byCzpZ7TPdsusPv7dVvs+nzD6S8BrXRC5DbFSbgtR
f21xz5P3PMvQM5/O3m8lswEF/rF1Q9HmYGDad7YjpVdrFok1O92CJo71YaZn62iH
3t5s4B9cfMcSI67s2QQW064rLUF0x+UrxoXfy/dWbQJIpiy4nXCsIvwP66s=
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
  name           = "acctest-kce-230707010002345312"
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
  name       = "acctest-fc-230707010002345312"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
