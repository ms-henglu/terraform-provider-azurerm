
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033357168677"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033357168677"
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
  name                = "acctestpip-231016033357168677"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033357168677"
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
  name                            = "acctestVM-231016033357168677"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd47!"
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
  name                         = "acctest-akcc-231016033357168677"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2rWe2fLGvtG5Qf/CQJaN9AYbIMFJFPlKFrrI2z+QW0xfTpRFDHZOi9VMkDDcvGLubdZYxhtTKQglhpjyV9i9w/PWISR4j8+HhJntxVyb23pN3sLFAt6hT7vkJYzprEAFUeAKLo2dtA0/r20QMPHKx9cpkcoc7gPTzr5OSGLQoIwhOOONfnKAcwvzANyqfkswdVs+/VwP1P7nT1wm5xMnQ4+KNydBiV1socKVX0gKGGGUk4xcqtK73aqTAIewfkGS4tJJXdcZSZ5f+TUtnlHbBfKQoXvd/MXacKXIUL1/XbNH05pjSj1XBk/jqZtbGaEEISZFfvILvjDxmjHV383S/ukkGfkuZzul+9pYOOrKm2TFRCaivL/NgqSrzSVyd7AXdxcdECGS6QtEItq0lFJBj0Dvi6ZAb2mH9ZVSYE6tD6vPmUZgo9NVeUA9pb+nEDrbCI6ONcIMYim2q2ZrDII8u/EESJcWRkYMpcOjf75UxAoIEtxQ2xqvohqQquUSCbEEkZmclqUQQjRcFTZgHIDorTUuFg2aRHA3CybX9zxKDx83+5/dp7HCW506RQfI+LVSEw1QVuGodu5ipFjwZ/DZogHBdmiizVyWh7PuW5teaMStyCQrQ0nOan+ZX9zwrFgREjAipAMCcPOZV3PM9/+C+iHjvOH9VfTBdxiPW4v8cqcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd47!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033357168677"
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
MIIJJwIBAAKCAgEA2rWe2fLGvtG5Qf/CQJaN9AYbIMFJFPlKFrrI2z+QW0xfTpRF
DHZOi9VMkDDcvGLubdZYxhtTKQglhpjyV9i9w/PWISR4j8+HhJntxVyb23pN3sLF
At6hT7vkJYzprEAFUeAKLo2dtA0/r20QMPHKx9cpkcoc7gPTzr5OSGLQoIwhOOON
fnKAcwvzANyqfkswdVs+/VwP1P7nT1wm5xMnQ4+KNydBiV1socKVX0gKGGGUk4xc
qtK73aqTAIewfkGS4tJJXdcZSZ5f+TUtnlHbBfKQoXvd/MXacKXIUL1/XbNH05pj
Sj1XBk/jqZtbGaEEISZFfvILvjDxmjHV383S/ukkGfkuZzul+9pYOOrKm2TFRCai
vL/NgqSrzSVyd7AXdxcdECGS6QtEItq0lFJBj0Dvi6ZAb2mH9ZVSYE6tD6vPmUZg
o9NVeUA9pb+nEDrbCI6ONcIMYim2q2ZrDII8u/EESJcWRkYMpcOjf75UxAoIEtxQ
2xqvohqQquUSCbEEkZmclqUQQjRcFTZgHIDorTUuFg2aRHA3CybX9zxKDx83+5/d
p7HCW506RQfI+LVSEw1QVuGodu5ipFjwZ/DZogHBdmiizVyWh7PuW5teaMStyCQr
Q0nOan+ZX9zwrFgREjAipAMCcPOZV3PM9/+C+iHjvOH9VfTBdxiPW4v8cqcCAwEA
AQKCAgBzjpC+8VJnUiJDJ+I4BBQ+wdcliFqX1Vt7BPfJOB2Kz6BvwVF2UzAPHAUX
Dmois1bs+9rt2VQoEuDY7Ajnt2IUncoeuslkmq8stbP2mobTAR0RvPEhIgYzPcA+
wuRYGX92EhzvGe4gSvvCMarjYW3WBu401IhSjf0keFKeVm+K1F9dUoXZMKCDqOWd
J/qBPjL9Xte6QCExVflbagI4B1uwi6/okjpDXPRfx5LqxAJpfW1mRDxWGYAfj9eZ
6ResrfLxG1CeX19CEYb+AkX3J6LE0rPuTqcsvlE7QazEVEtuc6JYwHMDr8NCV4Wf
gLEyqmunJDSF7VedBvkwknJBjNuUz5hmyV9r/2Jh31b0wrdpta59o0M5XOuktLGU
bX1XBxYBLwmmqjoNnkCe5raj4jL7s9yhXWAk1Z/Qc5vSnJmh5ov2jSh+a3IO4FbQ
4BL0ff7lTlhXey5HyvVYv87w6igpF/Lcg3vbNyfMWpRwbM7pbgkRsObvGhsVpqLw
CU0+cHqnFsFhDDtO5l/iOUsgowcAW+ci7Ap8uP1+OfOZqG0YYvKe8CTC+obQT7x7
BNqOnJr1QA+QCmwR1WzE6Fn1ET2uybmtjeQ7tWIlyO8joQ7+vQgUiDRTEbrQno5j
H9FUPFMimKB+hHpx8d8bJ1ERhS9sSMeeJyyhfxfxjG3lv2bkAQKCAQEA3wRo18hm
zw/uolsswcxveIWgQPSt9UVnwxWsoqtLfVDypvsPA1c7+LqGC0fTldztUab54v1k
sv69wYY+SVYFCOT6Gcicv2wcJmETO+v2gpjszr8nR6DzGtZ9V9lWjn1VaA6EcRNQ
wP5/WVbjBDR2TVNu4hOT77wcljL1dX/1Hyb9k6Uqu48BscHufo4PV4DXCnP7xO9W
Rr/mBGXnr2twcoL5g/UQ+FSsrx+T6DgIj/ae8Iww729PUCSIPthpoJFs/D+rNSSt
jrvlPGU3vJAwi1GWJyejlf2gWmv2MbwIrUyR7Kdq5rmBeC6OKFw1JAlELTL8kSdG
jWShLALSEmaCAQKCAQEA+w4dogWIuW1Mkm/Fwh/UP2eH6KkMTHFWS/4rORA6KSRc
7770Qy+PWZkXrkFnIg5mhIhLx6RoNwe+GsiemxeihLWa9ZEeRTKav7o+pBWO1XVA
X22LDhc4MTzYzH/jWi9/92QF6itVuco7x0au1LOpIXZPwXxKBW4V80IAfRF8tAsE
7WVV+OyZNQzm8a76q6bvAiKkXO3YxxWMJ1z8aM7aDjT2Beiy4eZRO8y0Q0zOtLKF
2wkniSq21UeT7ZD0r7TRjVRB+0FPz2hbz4seB0F+c1/71t/U+fvu20LqCIC8YJUt
tPbg6zARxrcY8c4hJ3RY6ZgabJG2sFvNojVTtdWkpwKCAQBDK5XUYDSu6vKKDgIG
AOgWGdExn0CB3jypYm7Ts9oRzX64UmesLusOOEfFQAX3XkpQTIV5G67nxpgqoJ9E
AVeU3TqC54xmj05PNO/RHXnqzdqNTr+q8Ewoai/odLqAQjmmFLFJSXMKHd0HcIcB
rjdvhNCh4RmunC7UAlcx469Via3YeWfMg/8TpgCKN4lhZpneOR68qwWGW6gQ7QyC
Jk8A/nfeicJpuT8lo9ItoCrcCYDHnMHka9csoUQ0AYSW6xYzR43ufLSVh/w8W5QV
BCzK2XDrLCI2O+S/N0M4qZTHdYeCCs7E3VykcQk6GMOcrfnNz0yI/5ZdYdC1a8gP
6LYBAoIBAEycZyCNLcbf+rDpGOD/U4axskCmbZFaOKph+pCkSgtKBG5IyENEXStL
U3WikbVLza795Jocqoy4eSO1Ouk7EiYLQSlUynb1VVHSpNDvnzG2YRl91SRMo6Iq
3kGxeRCJVDSLOl7WMIfMledew3U3ChKjBv2VTwVPLbWY24tO7c4HWs6S0ORwVuRg
do0kB2ygOWleZufQ0QkXozhT4Nae4N3a/YSaGRRkcz+bXRr4ck+j9sL7jSwHc9mr
yRGC3ZhMxnGpV6UzrgYt4253FofCTbMphDFzBovufFo+lipYFqQmgdcqS0KZ3aLV
NvB7JZTjpUpLVyzwXl589Uhdm5juhBsCggEAOHlv6fgI/2zAk6ilB9Vbnnu5CMDg
7DG/uD4Wr5LwUNxzSPb99JhLo+NCaUqK+f8wfZUT1hyQSRq/as6OS+RPlk5G8cbV
p0z/l2ItdipJA3t+Iq6GLnfaZYCkgGI1DqdOUQY689mcoGGQBVNDmt4c6lCh59qd
VljTU2SigJ7BsAuC0+4Kh4mb98XKZ1haZfFpcaeXfiAgy3CpfpAb9FD+6bi0dLPB
8VMF6gaLapMq12RHKTpofdq/q6o3blOOvBXLBMDblylzZmmEdJ0ZAyapaYtDRB2z
Lnp8ufzTthBSSZkNg65kazqtdoag8SeZ3RPXz+wB7mOiQnZWybq/SxAQWg==
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
  name           = "acctest-kce-231016033357168677"
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
  name       = "acctest-fc-231016033357168677"
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
