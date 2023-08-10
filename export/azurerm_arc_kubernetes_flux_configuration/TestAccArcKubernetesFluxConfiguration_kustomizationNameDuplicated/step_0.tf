
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142956934032"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142956934032"
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
  name                = "acctestpip-230810142956934032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142956934032"
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
  name                            = "acctestVM-230810142956934032"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3547!"
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
  name                         = "acctest-akcc-230810142956934032"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1Utiwf2ZxwkvcWzlIGzANoQ/6bTU3Yptqur9kcPd4gtkT0TYi1nf3l2/5RyUE+3Idtd9G4ax46S0icz3OWoaMg4f8cF+nZ5lOMWSEneY90zK3ttF8Mkb7sUYg0RT9rTLsvgV4vtR22vM8hOYL3nUWnCZ2wF3vsiE0AQojwIMa89lbCfiHUFChgNENZAQfgv1H/GSXR1tqAl1n3WaZH0I9xbcdVbsyZ1FAs/OsL1biIaIakAXWcIsR590Gm64q2w4QiSAx3HhAkhNDCaW2icAUnvtQ3HsENdARwlKryB1+xyaXUtf9NtuFGToDCoUJfpJLY3cyyZ1FgNJgZokwAgHYAiOt+VvyHQu6dF2pbjT1h8yxy7KdQRE+3hWPPX2PbYsJVYtz6BNrXO/vN8W/AYjYFMsXVzOxwRujFwoWCvhddF4ZpnBewGC8letwRb9tNV0VEa8xqtSrzfRPiabWoKpiUiljM5WFLbh53skCJRtyNwov8cu7TjD28YWFAp0IFKO/j5gm1FgSLsLGvlMZe7E0G2ijeATC0KEKrHdvRHjmAmg94gWud2He3zpiPJnychWjNWuGB4ox9Ng4EdeS0LqEqLpWsd7mw+YP9Zx09Axjb6Z48pMQZVeNwMYxOsgNsG0RFuceRqZ+Eebyao8ZKU5DA3vScU30aCT1es/RGoN5iECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3547!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142956934032"
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
MIIJKQIBAAKCAgEA1Utiwf2ZxwkvcWzlIGzANoQ/6bTU3Yptqur9kcPd4gtkT0TY
i1nf3l2/5RyUE+3Idtd9G4ax46S0icz3OWoaMg4f8cF+nZ5lOMWSEneY90zK3ttF
8Mkb7sUYg0RT9rTLsvgV4vtR22vM8hOYL3nUWnCZ2wF3vsiE0AQojwIMa89lbCfi
HUFChgNENZAQfgv1H/GSXR1tqAl1n3WaZH0I9xbcdVbsyZ1FAs/OsL1biIaIakAX
WcIsR590Gm64q2w4QiSAx3HhAkhNDCaW2icAUnvtQ3HsENdARwlKryB1+xyaXUtf
9NtuFGToDCoUJfpJLY3cyyZ1FgNJgZokwAgHYAiOt+VvyHQu6dF2pbjT1h8yxy7K
dQRE+3hWPPX2PbYsJVYtz6BNrXO/vN8W/AYjYFMsXVzOxwRujFwoWCvhddF4ZpnB
ewGC8letwRb9tNV0VEa8xqtSrzfRPiabWoKpiUiljM5WFLbh53skCJRtyNwov8cu
7TjD28YWFAp0IFKO/j5gm1FgSLsLGvlMZe7E0G2ijeATC0KEKrHdvRHjmAmg94gW
ud2He3zpiPJnychWjNWuGB4ox9Ng4EdeS0LqEqLpWsd7mw+YP9Zx09Axjb6Z48pM
QZVeNwMYxOsgNsG0RFuceRqZ+Eebyao8ZKU5DA3vScU30aCT1es/RGoN5iECAwEA
AQKCAgEAvWwXpqRr3yE/KwJEcglioofMoubfbGg1gOb0jnFeKhNn4CYKEaedc0Pa
2cQJlbFEqJYzGzEB5mMtmnuWyzx5Sx7UK8VlhuFWj5aWZSQliup9+HDPqklQLzqG
zHzv/FcP2D8OYOhFCBKyjgHs06zkc/UwDhk9mQdHO92Vj3uIQG6NagH5g3WjeJSK
DO+GVgqUhOvqyhsKeYL9HMI6fSe1wIpi+ypZW6v5z8dxjfB8y8B+ga2tjx8sZ+cq
GxddlY+kXslAPN/brkU7d6EFs3OTi61XRuBzf3lKMkwEMYcof/wk8tmvvCrrld0P
X043WoruVjB4d0oODaCZtSmJnakDshyYH3E2+S/5SxQZR9BV9ZQYSWLJovVGVOvI
Qhq5zrUM963Md2A41gcqcYeGrjfJVX+Qo4XBdRsLsMOc9pYtkp0aXcVEjrODI5jD
MvvKRGXlxeFR3Xg5oT7WeNN7reXBj6BFpe3wpDC24wsvAwRD42Ihmg65tCl/yNm5
RcHl38FatmUngU+njzX/I3Xyx3E27n1ghTfLpyN1jT3TGqMlnLeOtBYBfJAFBvzp
GyuxiGsyWeoXGwHZ1IrXS/u48hG78N4h2OCHB84xCTTwUVe8X17d2tA4dvTg4K9l
2NsPnlHckFs4AWuviEwKODcuGTAUp7KtHCgR/6NQPA6KPwq8s4ECggEBAOffxAkW
eeYxvSKILNgb05E2dSHPCkRfo6rsQt+CHOJi2JTm0oxT5lQyoCPMyRxyo1523h5F
GnOcTLxg/dQerYU5xNkZyTkSI85Gaa4qbVzAZb/y0vhiJU6V4FPDi7bnI9k+INYW
jEoNauuZ6/aZ2vduB1jD0LtFT98B6wq6mxmRIISU08wc5rRmZNSwLBOozq6fy321
nC8JfZkNlGKcAWtKus6vWddKcJGTJThP0ZfrWiCMMw9iEqBdmjhZYjrO4OgfuoLU
+6+QeugCxlQz7Xi+VWMDvhQBPq09EgzQzod/NOvJ3pUVaKRf8Y8IH8O+uvi5bdTn
AMYLcR/brVr5OqkCggEBAOt8uwtOHYisafct5ggzU3N9ZEFzjttoNJ011n/t7use
BSB6LEDHEjSHpXHy4amEw+tLrry+SOujMcojIW4qfrVYpj2Yv6NKtgvk5IIX68M4
lziGBvkC4fdp8GPHgEAedYIHw0pANa8Q+bbulvM3QdV4nEwYAKtBm8ZGPlONbD4g
hLXEd5GcPLGTS8G5AyXPutLjLzf8eoZbA0rLvaavFcXzuwTW6vuvFPT1/gNZ/XbO
/Fuptv4g8fcz+o8LvxW3DlJUWXf7Qaxm2W2qiVGZd8rsdyTcVRq0GNJA5c66jEMP
2Sbb87KUlJVZk6Rq58FnogtK7JYO7Y+lGddQ/IKBsrkCggEASVybyoBI+xLbk1Rg
U9OiAXyoXJUD25Qi1U5A7jRdbSb2/U12ah2VbyhBUHJXYt/GXnnfVtZoQxG9mZBa
XsWCAve/Fy04ZA0gNQBEKW2VAlaBGtT5+MocoZt7ySTCTJEe33nvq6ygoEFUhcxC
Qth01foC6wuxO773QUh7E/7sWY94KVppFFhEieknl79RgrrTAZ7fJBvUmXE4Qrdw
Li7LqCWRqxkBpMMRkI1spj9iwd0du9R/xysxV3ml9JQbJx4TPH3lZcV7CBX/PO67
zyJKzPvzSguCFRQ7v1XmIxXhci9GEB/jg2mtnOwaIjXgzu7GezE31bdsoDw4g2re
kzztWQKCAQEAjWVUjiI2W5Vi/xchMzVWW1ckNqSjV5zHUso75I7CUYyx+WFCZxbh
GIeGUNhMpVPhq8vCvPPopwxTXhMgBJ0hfdQf5YZtMyguDRBAINkqKAs3yam4UBZq
BfwnalIk8NsZJZ1xpojNczPXLP8vxhQcxIfqGUqkRDBdz3zn+ZVGNDukU9wHC3hr
fRh7eXOUr0R+4helh5FjJH9Lh8K0OnyQr058shg1+i+Tfs6h2fNT3N3F62gJR6gS
gaNFRFUCRJCo2chp/D/ynAkZbt7iGwvyQPchRxHBTAptiPmMw0eB5taCRfH17vmG
CfNCUowaYifOxccULboC7KhuzrmDFP25iQKCAQBtQSf/eBZmtHuXbMUqX6O4zVUk
CIqylj1nGQFpSnIOO45d2/ZoRaxW/PrUBipFeRgOBkTalQ6RTtKtksrIY0YoCN+4
IW7tvKB8aLKgAV3Am6MCrauJ6S6ks/eOoQo5okUworMPaH2zhI9kdWZKJGg9GH4f
RqgT5k/S/r+IQGkuBnwL6ASRHX9yKgC9AOxsUVfMnu0X5p/g7WcV3vej0aV94Hpa
fbIjP9V74nBR12qChmcCs0/UlHNzpxxAN/XJQfQFZ5m7njKZ8RPrjfw+oZsGV8dc
iuN0dZY3yJlDlltKYiOiq7iythlGKJmDz+UJflUbXiOkkT0awgZPAtceqau5
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
  name           = "acctest-kce-230810142956934032"
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
  name       = "acctest-fc-230810142956934032"
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
