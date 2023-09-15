
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022859732823"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022859732823"
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
  name                = "acctestpip-230915022859732823"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022859732823"
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
  name                            = "acctestVM-230915022859732823"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8580!"
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
  name                         = "acctest-akcc-230915022859732823"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz2ujAeVVoXHLXhKz6+WlGLWLpWebY7oc5AbH7UznEH1ov+L8RUTMeEFau8n9iHybaZ1RgcWi6aqaCqAzGs5PEVM0dNBiawoT0gHqBPhj+uCudB22cvslG0lDXAzOAZhDonNwUItTFugmA/x1mISgE/KfZKwJPsEuygzcQ7OhpyU4hp0iSnNV6wEC6HeL1eFNhk8V6uYG2N8ZtNmONrEddQmP5pSvoOhQCSWM+k9lv9nJfHJE6dGrdz0ILGSWLGtNGAQ+JQzIjjRfJ9vePKmkPbhljpHKpEsCtwlr69sMzZ69+xtvVTkXxlff3JfhXGl+YLq62Qz5bCA6qlcpXe2xKJrzF0+IGfYhjTFFL6phJbwWrIHywuv4SMJCyaC/rAW45eSLEBFk7HHt+vtxQfoGDRwdV2fJViRP212CgA8gSEuONJY8r6R6qiJHDHspfQnYvX1xNEpOQPqkCJnDsbDyNErXk0tiNPbCXwX+CSp0ZXSAfffAmxWSMmOtx4y/JQPq/ONSS8Woj2/Z+jLAhqTPLzwEZFcWgVuM+qZebHKVjZepVN6BxrjkVi//Hi8JOStch+zmPKEUCaw7GXumKw/J0eXye9EVHrwdcIxg1yHp8/wMaCuKz9Xunv1difGqf/flF0cgRap02JAfCLADMW3VMU6pTXus2KWn8F125cwYNckCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8580!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022859732823"
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
MIIJKAIBAAKCAgEAz2ujAeVVoXHLXhKz6+WlGLWLpWebY7oc5AbH7UznEH1ov+L8
RUTMeEFau8n9iHybaZ1RgcWi6aqaCqAzGs5PEVM0dNBiawoT0gHqBPhj+uCudB22
cvslG0lDXAzOAZhDonNwUItTFugmA/x1mISgE/KfZKwJPsEuygzcQ7OhpyU4hp0i
SnNV6wEC6HeL1eFNhk8V6uYG2N8ZtNmONrEddQmP5pSvoOhQCSWM+k9lv9nJfHJE
6dGrdz0ILGSWLGtNGAQ+JQzIjjRfJ9vePKmkPbhljpHKpEsCtwlr69sMzZ69+xtv
VTkXxlff3JfhXGl+YLq62Qz5bCA6qlcpXe2xKJrzF0+IGfYhjTFFL6phJbwWrIHy
wuv4SMJCyaC/rAW45eSLEBFk7HHt+vtxQfoGDRwdV2fJViRP212CgA8gSEuONJY8
r6R6qiJHDHspfQnYvX1xNEpOQPqkCJnDsbDyNErXk0tiNPbCXwX+CSp0ZXSAfffA
mxWSMmOtx4y/JQPq/ONSS8Woj2/Z+jLAhqTPLzwEZFcWgVuM+qZebHKVjZepVN6B
xrjkVi//Hi8JOStch+zmPKEUCaw7GXumKw/J0eXye9EVHrwdcIxg1yHp8/wMaCuK
z9Xunv1difGqf/flF0cgRap02JAfCLADMW3VMU6pTXus2KWn8F125cwYNckCAwEA
AQKCAgAaavAg/q+QV2j6e1FVGzOS2RSHJZIB+qNRW5e9Ho1TaVWdEvDkdaXBLzm6
LzjOWGiG5BWMfLqKHkNuVQcNQ/eIElvdAOl4DpmFpt7CcUxymIk/msUxEdGhDwy4
PZ1DULxUhXVpnMUhZsHowg/MNCAbSkyIyuyGhJ5L96VaLhfJrRDs/Dhw2Q25V7Ci
IQ+7Vu3DzHDTMSbwGkIw6YCWcKp6zJP6XzebO9ttvs2c193yuG9UHU2vphe7oRdY
aBtEXwo7o9aya1Vj30G7VuKQQV78yW6N4P25PSCEZXvMV2LjEXPK9qyQYywnA+ws
MV/voDQLZ90CZgeigNxX86/+GZb1hTNyrDcICjbbrjuTAjX1RfWhX+JSom/LYZFk
xsXYIN+JmV1biExg3iqAAMe9uQbINxopDHgWBXvJ97SkFvS1k0mRt+q0I049L7xa
wUW52GrBxA2IaAVVWgH+WDF7v/AT6C2iQoxbdpF7Vmq9FhC0K6FrF3hT+/lh5eBZ
111eCIJ/8i60new3ohRctZA7oq9JS0t7QrCNRGAian0d0p7fLmW+/Hxaw87vp4ND
V+R+3DYVaUuiF8JPpIeSDrl1UxTJj/GeoBO6QAMeQOpQUTDHBVoAZK2qCx/m69T8
PRYUHCtBEnu/s2Cqz5wN/pLAV6zXveLtIw/qQWvys3wDYxkfrQKCAQEA2ajBRpzd
GhRrFJsKNlMHAXBlw5jy8KgHfEHwcGxdGRVVLMBmYIkxEOJ9hi2QlyvOFMpGauI5
gx+z89CVJMLu7Cm8HKhBVs8EpnrX2SBiMV8eUv/R4mT2PQAewyZrdaAEfCljV7VY
O0HYpzgPhbkTPR5Je61v6LSFFly9JC/tHTRmcCHmaiBCq05/Ft6KzP45ycsBbQxe
GphZzLY6tmcj6BKXogO8Ae9AT77UtR/3dmbHsjBHJi641Lve9U1Fi2TMCdC6d1Vd
wTgDeK6el7MmaeqTMbsxX6GjrpGgc9+LcdfQjqEQuB3tZC8dfLJEDisyvtNIGuE9
JSi/N8ngBblsewKCAQEA8/UrkVDuPt9JB27yRa7/mhTMuUTZX75dYu6HLEILVkaP
bsyRSc+U5w9pHY6SqYfcJy3EcpvlCeZ4s/0v9yEg0VtM2QLPOCjTNn+MBbpfQ+xZ
+xRpEy3L8RftFWaH2hp29AT/8rx5BwsQFIziKBDaCs1vUAUzM5JDmzXA1y2844m0
NZWU2HxiCx2wmWKLiHnjXSk019PaicDNjCtEXBJjBbYp9ApBjA9DYETceKiczgys
OJfcKmAa3jUFRezQpS1Wb/wjAyCBt2lb5p/+9RhXbVvGWy+AQklcekIkQJjVuUJT
0x+qQR5jevok1xmh4emfCLcqpGPH3uRWPobvSmM9iwKCAQAKzcKSM7UR11OdWTi/
i418d8zFUbE1WtHMTCWYHvjcBuAMcZxjTEwAL43VfCuCJW18QLIQGhyKsqcnAgJ1
KavcUxIARiXAHlR3wv81ytK06qjBq+sKFsLWMkxUmXKaCxBN7Wv97YVso48Sdcjn
dVFMJlW1at10Kom0m3PT+QEHAxPWmwgp2mIUyLesNe2j0TajGo1+kS+WmFtUuvLd
HO9+VHXsV80cN3j0vF8ogmaxHNbqtFTDw2vvO0gM2wIJsj4iepbW14joz1P0yI4c
r4rHlRorTMRdn9NVFetl9QGh6/lxKvN+gBXJdEE9cEfKgEBrkmcw1l9Hmecr6LxS
7GpDAoIBAQCK4W7NClKnLjwH5Ew+CVLvp5moex54mAnX8Uy4kFyd4At1mzW23Fq7
c5V2wxyRMIvPLgng6Qjpqu/aH2/38z8YkC5eeG/5W5xqMRBIjoH/TAUpn8P1rCOm
++T3Quhh7KD9Z/9Bc7Q+ozijSlTRVE6cybjtyBgO6txb9qzyktIugs05mA8lcyHp
jBxmJaijqCgceAHiQHPv6ffaLSN8eucucDbP/Cq2jlXf7zPH6M1jq+k7SpCG+zEw
gOSgmyFodzf3BoX0GMRf4rXzw+/EHfhfhFiWvqL4mYTxAMhckeVR0wWfci5dZexi
LRdd8PSshHAJ6SR4c2lsZXcHn4+IPJjjAoIBAC805u0agHsiHwN206K1nlw7+Uzc
Ez9W7Z5SBtS/Eu1VnePq5QYvREnbSAO6wuBXPv1C6QNmZpC4KXuS4Sk4xMGOOi5Z
v58mjX5MW2b87un5iePbxd5/lVnhCy8cx/YqSByHjWofC4U4My+FGm00PmuWj34Q
oe8I5zqV5JWdHy7LkFuvnQsPPQG15GQRuExKja4xrmjaPTM2wi25u8yXr8V4quMZ
RlM89ajcq1gNJU167+oMEiR5mwzgfQBK/LVehdOlYbZYJb0y0HVXAYyYGPWdf8Ix
ilvOmWFIRh1cptio+Ut7L+ZnofDw6evgc4O+9RziSz9NOB6eMDVgEvP9KAY=
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
