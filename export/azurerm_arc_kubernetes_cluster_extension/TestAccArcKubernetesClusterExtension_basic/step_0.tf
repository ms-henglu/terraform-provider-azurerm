

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030124738736"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030124738736"
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
  name                = "acctestpip-230602030124738736"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230602030124738736"
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
  name                            = "acctestVM-230602030124738736"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2602!"
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
  name                         = "acctest-akcc-230602030124738736"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAn/8vqJweMC/dDxmkxv4bKOdQ7Eqg3dYEgHEfOTkIpkVloxX5oxr3VbOxkYikNYc8w3nwDhobFPX+aVM+DjKWEN5Uv9fPA7DrRR9uLdlVSBDAsmKWMqEmizRV5jc0BBerDtKJO+p8vmrqcwMhDuoVL5RItlAmxSSubsRalD1urJLqwB/93o2g51Qbef4L0OqMOJ59mGHFAzpYuNZWIECkQpTQmqIRzG1v7GEB64MWfAzs9TJRzHN3YBnntJRQ1tjaB47xeL87CaCSMJhlPlFJo4iKjNYCbCY7B4rLSf3omETCjAYfmwRiKBhiXLVSjPpQmw+99CAAxoyOYYq+dA4uxXZ9pXUoq2V511XRKNyF5ovC5yp99KcfpsK4839frABQ1km+MO+8saIGBkSbnh2BnjgRVWdfY4T+l2rYksRjXTMjoyrJRLQnfRTcA/tnkdq9FxwjSc6xJgJYaw6FrzJ1RtzjbDCnVV53zDf9UV802rhH9htqbAo0+2JSrKzeTxKWPso858hZVl46WoRArlNrEoSDllrSHRyAkdA2lWEUGdb+mgFIyXFmOfdhc2S7Ax0yr9129jdxBWD/ooM3fvFXt/d4rRS++omauWWs4lGkuxo54HzX3k4k+AXoXZZGoxLVn9xeMMd31Z4xVrzbGU44TvY1egjhml7/7dQXplF0XJUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2602!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230602030124738736"
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
MIIJKQIBAAKCAgEAn/8vqJweMC/dDxmkxv4bKOdQ7Eqg3dYEgHEfOTkIpkVloxX5
oxr3VbOxkYikNYc8w3nwDhobFPX+aVM+DjKWEN5Uv9fPA7DrRR9uLdlVSBDAsmKW
MqEmizRV5jc0BBerDtKJO+p8vmrqcwMhDuoVL5RItlAmxSSubsRalD1urJLqwB/9
3o2g51Qbef4L0OqMOJ59mGHFAzpYuNZWIECkQpTQmqIRzG1v7GEB64MWfAzs9TJR
zHN3YBnntJRQ1tjaB47xeL87CaCSMJhlPlFJo4iKjNYCbCY7B4rLSf3omETCjAYf
mwRiKBhiXLVSjPpQmw+99CAAxoyOYYq+dA4uxXZ9pXUoq2V511XRKNyF5ovC5yp9
9KcfpsK4839frABQ1km+MO+8saIGBkSbnh2BnjgRVWdfY4T+l2rYksRjXTMjoyrJ
RLQnfRTcA/tnkdq9FxwjSc6xJgJYaw6FrzJ1RtzjbDCnVV53zDf9UV802rhH9htq
bAo0+2JSrKzeTxKWPso858hZVl46WoRArlNrEoSDllrSHRyAkdA2lWEUGdb+mgFI
yXFmOfdhc2S7Ax0yr9129jdxBWD/ooM3fvFXt/d4rRS++omauWWs4lGkuxo54HzX
3k4k+AXoXZZGoxLVn9xeMMd31Z4xVrzbGU44TvY1egjhml7/7dQXplF0XJUCAwEA
AQKCAgAydGvYFRtkAMQKbgDLi/iOppubWFFwg3w58PJyviyfGoVZr6VgrTFQQnF9
voRiKPqdfkeYet0NeCG5nzmTippOSX6aXPj4ZgNbcfTx2naNWlMaLgLFhpI8Fc38
4m2x2LDl5LjIP0MFXXv/tv3m0STLM0zWyWHgi5fCcINL+i97ln0XBz+svib+rERZ
7SZWxJBhjoF222YghXbTGyxf0WK7aGh8Sx2nxN8lwNW1Kkqd5gmXrT2kZsk/cgvi
o1720b234nj9pfh9KbjQQE61HzdErdtbXGW5Kzk0QK2o8Lw3wH9FXuz6mqBFmqLy
L3AP6yQeMhGp+amk81A3LGSw/oP6247xWZkucA5xhxROO0Gp7T0jop80myjtlgA6
myhwl/zpZJOZF1CLy7YuhnQy0R1obrWkXl5wl3Xt+ihu3OFCnbv64D9dMfqJQh8N
FnRRo0zmsfwtLMmFaLEM4q59M7B+aizzUhycbn7U/GSwBLwjY8Mn3nbyoiq9oVeW
am+p4x8h+Tp5H/ds8hU89jYKgGfqOYjVxaNxHmCgaiAVZMsQpWfq/i0PIEbl7ESW
w/KtH3LlctdGfktPra2FePldinW5p3sAIsJQrPJ5i+oqotCLpcCnU2T/+PDZVE4R
0D4brh0BxMmY0e0Z6yugw7l+/tT0OXCDzPApCO5pfN+ao2rMJQKCAQEA0fA0Rm+z
KGx799lTvNfKBPNlYdGHKQxowJ73CgoI7PuLeDnUrwXoESLSJmkJojSxV6W1zpUG
BpupIDLx1xFtRBlITYwlXkzea/gjBPICuiQy+tNpwMZZmqX9whaDNkzgug3P+1di
8WPX/MpX3wybxARd62D2tbP8JypDlEH47HTSHep68niraHO9jZsrWFjYxeWaTQod
XSKNJefB0Kk8Xn1wFgQV0SBr6q7p825qC9nyiVn/LnKntRPImut5s/AKCr/wLc7e
cYE6UAF6lAfqfmFlkNheRr2ypf/TUfpN2AvJRq4XESmgpcVco7uUPgx58+kL0mRj
/vWS52ftW4FwqwKCAQEAwxnfngykiYrwvx7fRie2Gb49vuCiuhIX6DC+6lpcCAey
Llg0h3Kbx+K3sjMb+l/4NY371FyH9QvlIvd39a4Aviqwh3gKmG/XfrvUTzf7kSNN
aGO953WqYCj5i9zopcmpphTZ/kpg50vTSqylYD8ipr12GoXu20TJa99xO+mQl84M
EDEmSWDsPr6pAqY++8jTTKUBEI2ijP4u8d+MalJx8lXHpxDCeUpyjtPrTgc6/NvE
+XtMqKBAJ1qv8mTvwDHoDclafb4pD1pC6qpx0udETHd3C07e7PjTeafhCHuaL0wZ
rLkV9v2oJx0V6ixuLjXHLinuFu2DKQ/WXmv446XnvwKCAQEAjoe0FfYT/mfYqmak
EVu3zjCpLgYg619/ZvcF5Yz2jl4hTFiG6uTpr2iioG1DmxqHJGhezIgkdSwNYMz1
n/w24LsBeZSiciliAI+QxvS/oTyeV+hcrgJ8JyB27eR25NDA6dAi2hN0G0qcAwYl
LkvTHPuSABHurWIq2TQ6eVdo9rBBTwo4upHuXZXmpVMp1GtNkN3XKmKpmOeySH/V
+CJN2CD1jhzr6vVGDyj9sMXPvYgUv+eX9iLldWyfD367O8zGJJI3MAJ4xzrjKho2
7HWLYI4jdHlRWFnGBilvgQKdAwbNee0LwB0w8hrSUF8zwAScb1pTKl35/ckgGXdX
kH6KzQKCAQEAoBqadGPhnnGjcOOPzE2IVYXVu88yGsoATm26Li0quvg902RU7xYx
Go5FuvnQKt4YnTJAB5xLgd9aESDNk5JQT75OkU0EPOYDDKBs8Pl6+zbiLhkz3T6l
KzZU2t7VGD/udTlFTzWQYh7KbMxTBjGpaPWvdsKUKeI//MMndEgOfVT8d0kuJydf
l3n0zhTJOOwr4gjCX+grDdMFiT2vSA0SLxEPv1y0ir56VhU4UxcB5EEhWq5BUVv4
aZM1MhB84tbRnIaxOOEVZuDmaxamQ7G/TZT33xLBQ+xJ9tq6g7CS7d9gbmqQyNiN
5lMrCbmeTVOaeZq1JKGScd7qRyAJ5h7elwKCAQAbFuvoCAsVSAy03jzIWahtBQTS
zCDV0e3bT46inxbnh7jDArAnsFZUXscVMFPNBIG5tgwAlcKSdMjSG5P5AT6Rf4We
9hHoLQ1KFeRiRa3blN2vObz3exBGsxu0Uerap9tGug5V97rJvonz2OnE2ECom7tl
29kNhi6sLdi/jSQ6EOmfPw/8uSqEy4gAmfYKoJMP/9eOr+5TREJ9zpmpYq1OrYA+
ZCFUXP2yshmF0k1dyEMeiqzLz6eXAmZSr/OeJ3W91n6yKr6HGH2tnY4s40xsT/lj
sAavHUMJ5wkyhENyT3OFC1m8JtFy4pWo6dth45S64BuPCPH27B5kMP92Q7R3
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
  name           = "acctest-kce-230602030124738736"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
