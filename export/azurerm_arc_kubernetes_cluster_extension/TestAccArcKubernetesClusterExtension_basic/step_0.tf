

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060543937221"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060543937221"
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
  name                = "acctestpip-230922060543937221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060543937221"
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
  name                            = "acctestVM-230922060543937221"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8696!"
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
  name                         = "acctest-akcc-230922060543937221"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0/N2qa1y/jkjLnoBK3LzrJNdxpkyWbFS0vQZ4q0eBfIGNRioOekq3d7LS8pUanDN1tRl4Hvrb+X+JoMtDDZVMnN853D25wsVByYXazXajAeUkDwPnpIuoZw7NlDDsV80NnhzoxBTK82gylpiKuRWnPEdeddBK3zFS9/kkTqb3xx3uEKwhveKMnUEJ8z1Sb4kLLQ2B8oZ+Vtib7EBGOBcZxiu5FL3NuDWn+e6cX23+WnvVjPZNAg1/+uF2egzPGoegMGlcjjs/GPF7sg+awioTB0GELbk6qOOWZbMBYxwV5cg1ku3+3VNZ5DuxdoRPxZrnShrEOMtzSfZwWZ71VoYVLTv1j8hieJ7riVJ5fQNroZLaJiEkSp5i6RwjwmiAoWzMeIBBtHmUekTIc0hZlj9UmW5fwiiwua1LFn4m9r94LHI2x12a58CNVZw1R47lnvIPz/O3IlstByv/VZCVW1LuthW1WwrM1lUx+5fmZAO/4heSGplosZt+DPZDXYyEmN6TGGPIDkH4Dy9cdQworbDrucY2WL8XNWEiISRV/jBT4INxVJKsytpscl2a8yNgPOhOxWvMK+yEWPEWSLP25nE5isVI7V7xNfsuajRSpp8IVw7otMg9I1ktKJxunugS2gH5cF+t+cahjIPcRjKdQUkRARaZxyx+nsk3TtSaPrjdXcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8696!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060543937221"
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
MIIJKgIBAAKCAgEA0/N2qa1y/jkjLnoBK3LzrJNdxpkyWbFS0vQZ4q0eBfIGNRio
Oekq3d7LS8pUanDN1tRl4Hvrb+X+JoMtDDZVMnN853D25wsVByYXazXajAeUkDwP
npIuoZw7NlDDsV80NnhzoxBTK82gylpiKuRWnPEdeddBK3zFS9/kkTqb3xx3uEKw
hveKMnUEJ8z1Sb4kLLQ2B8oZ+Vtib7EBGOBcZxiu5FL3NuDWn+e6cX23+WnvVjPZ
NAg1/+uF2egzPGoegMGlcjjs/GPF7sg+awioTB0GELbk6qOOWZbMBYxwV5cg1ku3
+3VNZ5DuxdoRPxZrnShrEOMtzSfZwWZ71VoYVLTv1j8hieJ7riVJ5fQNroZLaJiE
kSp5i6RwjwmiAoWzMeIBBtHmUekTIc0hZlj9UmW5fwiiwua1LFn4m9r94LHI2x12
a58CNVZw1R47lnvIPz/O3IlstByv/VZCVW1LuthW1WwrM1lUx+5fmZAO/4heSGpl
osZt+DPZDXYyEmN6TGGPIDkH4Dy9cdQworbDrucY2WL8XNWEiISRV/jBT4INxVJK
sytpscl2a8yNgPOhOxWvMK+yEWPEWSLP25nE5isVI7V7xNfsuajRSpp8IVw7otMg
9I1ktKJxunugS2gH5cF+t+cahjIPcRjKdQUkRARaZxyx+nsk3TtSaPrjdXcCAwEA
AQKCAgEAreEtN1RhY2hykV1r+j4q5ChdpWDm6qhLv16codbOK6h7KTIaSLAeB7kQ
ZRQPHud+JsFG9twSsVEoqGWzHjKwwFv4W1LUa4Uu8hdw3PZoXbqWSaHMWpWohdLK
zOuDL89f4VP94gexg90FDR0LLg73c3dnbB6Ii2mn3nBGblJ7r5UGLncfpQoNKQnQ
p+pATQgdW0NYlBlcJ7Kt1d2LfeIKTFX2nL/nqfDYgoSz8wllVctvmvOcPFCEJHkO
7U7OQcD5Vz4GQeerm/8qUZObiWmn0BF7eVjiAhC95oeMxvyI6YLFYKjrvfJk1xMS
n+Qfg/cbv+l5tHf7ijQoM76k1so77DqnZWSXya+RV0GVLeRe0RnyJsyX3uuCbnTi
w+q23aIXMS3tPEhszvr1o1AV+/FvYFLMs4PO4TUrpE12q7Mp/dAlcjpYPQ4pstHd
fFzIoNqbksf5lo3Js3m+rhdn13ld+NQH7dozlQnHc67SHKDoVsvkSYYSDQBR2j/9
qPZlT4PEjuuIgqzRJFh9rOrcvB69HyPy6m3hpBhA7+OoYE+JAiZbZ9F9co5z8MBN
9HNll+5ncN4jXVth4xBFfA50eUO8RqPtkrJ8MQgmvjuOjAZrM5hdEUis/v1XWwks
9JXTtNhQfGmxzPh0LBH5KNcFtikU5XPS8ruKUOrNnJ0Z/pCcoyECggEBAP0AKdNz
kXHi6RR/Ynv6Rbm/fWShUoLbx7mru9GhhHa2AvmHZ6Ds2VaGpd+xE7pFuchhWC/r
ifitYJShnAWeGBcG7Zma+L2KUtc8jdLjGBrXuOSTU1xHd8EUmqWSP7E904OBTxl/
mpp9E6EmO54oqsX5FYOOI9dUelMEPknK87i3wm3scCGjysQtmnCxpNkZs27+Gmx+
kG5Kk5Q6Pn4Ud4C7avGS3x+REnOwn+G3fkqW+w5oGruImecop79GLcTcNGDIjW5N
LdOMjX5swUVBX1HWbSIJAUsc/U0FNPQrPxj4cs9BeDOMNCsgCCzZKNiDojFplW2D
TfU408JHWt9oxmcCggEBANZ2t8bZ5zTXHMlPV3/EV9Idw3gxQkRS5qe59dnx7iJR
DOMLh/T9OdFHMHICv0Aw7JKY/LDesxgqVB/U4Jld7neOB+UCA8K13pql19FUGIZt
5GvUSmFh2knkwqqkHrMNkvyhED9hKhK2oj15YffgIhFXBtjTeNjZlxYPYo85xG1s
I40fukUSwxg6Vn0ST7aRBL6AntG2qin/pHoQcvinBGngQNezc8n+J/HqqmxseJUr
LxC6Yw/kPhO5j10beLipUVE5REy4WJe6zhxrO6oEC0AKIljgagSG7+IO+Wtc+v79
cn0AY7ErdeAdKKtsEPPGfOtSfjkbe6kSyKbSXeH7znECggEBAOSLez0aju60Lh1o
HU0lfksXYmy/FkxDwZ5GNnpeT8z1Cqbi3IgQrRxusfTqf4mrZvJOjV1shsxvwmlB
vDGO6PAUQBqcVcrS45aviuZQYvwMl2dUdt9LaDCxLioXfRXdZe7Lpuq/zKd2CX9v
jDeJQQtpwTd/9XyVQZMwqBv9DEF3LloiVgDtd0PUdkkLEIFVqDPBs5kCk/ItyDcE
jmNSlclihG8JYCmh4WtEyIkcOyeiT9Rp0oxKD80zeqVc/gdxbJdpU+mqKpWJyF/G
Wqj3LuY8r4UpYVO7Mk6bP4S6dFtYRE5ZM/5MzuuOGhR5b153OtMsL+In1QqKdTBx
SPO8ME0CggEAOmzxOA0Y/b40q2sgDUCyJB3TqKTSxsZG7B6vKYbNNzAZcKktisKJ
w8e/HPA+pgAuEun2vUCOTeEKNfnKjj2Wv59D61GXMK5XTI4ts2tTmxvJBM86zDja
PRNDLTW031atWoGOaZXQ3nQ+0ryEwgCfh1XMGbnSzFDK5kmesiIsrxqsvL+OAU9R
MwKBmWUprjTns/ZaTguTZAmvB0n/6FmnzCg5wgmzW64Pt8oUT6FlYE35bnc4kZW+
i6Ubt2PKiZQnARe20afPCtbrW7ai9HhRkEqyfL/2YfFY3J7zuBoGjv0A+ajnf9a1
MC8Ba2HvZFoIohtBI9Gm6LKjUz8wMGZnIQKCAQEA2rot5thcpAQyr4V2+rhM0ZIs
1MVtBbTlnhB8nxhKclwehyoyoyTTE1rDYg11edGL37N8NQgETmUSg7Y8e2v/zsUN
eaj5uPNsan1xkj1p1cPNyNhXravFj3HUkWmhLP3Kyzxa8lNCJamWlJLMGsWiAewU
I7hADfiEk3q6lDx2FEpN4FDAH83ZyVoOGsPfU4TnMZ2Gw8Fr565eFITIdgbssVcd
VvejfEVRH5CCj1FCW7GCRTgvE6O3cYZc0B830jO2Xix2WrYH0XfS25m3T1EXouyi
Mf2CXCIFpLxWkCfFSmUEux5MlbMArXDs2HPlTtI81m4Vn0SHVbB2V3tJfJa6Wg==
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
  name           = "acctest-kce-230922060543937221"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
