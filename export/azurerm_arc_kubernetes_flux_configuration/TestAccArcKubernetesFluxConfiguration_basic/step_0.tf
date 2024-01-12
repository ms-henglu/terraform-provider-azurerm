
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033833282629"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033833282629"
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
  name                = "acctestpip-240112033833282629"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033833282629"
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
  name                            = "acctestVM-240112033833282629"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9393!"
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
  name                         = "acctest-akcc-240112033833282629"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsGnQn2UJZFShpB4xuA8wFzF1VtGanfjAZ1TGUIq8o/FNuG8RGJ21AhFWVLPKmYTb9xZEkV2DG2QzcWYdzwm6ss9rJq3nB8VuT3nwg9NRDb3CE12swfiGwIYJm4EeeTVTC5/5QCsFg+ghgp5stSsOf4GRaABwCv3YFEBod7GaTfytt+I5IJK9Jtek4OXMv/pKp228FiDy0+c5dmCQvfGhqWwjEljeNFEsVBVAOaw/gzcIspyep2kcQzDNfLm1W/tGi8v0WKEgoqhd+1NQeo3w7H9zKZg3+y1ulJ1YzN0slQzcH67XZ2gs3+Oi9MFHyIPHZ2zflC4jdXV6R05tMIVC5n+2dN3eYHU3S9P+0EFVecrk/39Kei+OOIZ/72VtOnjk9DuMQY49TafLOlvADPYZ0bX1sorXS4aQVYvl1eIarXHNFijEOwWu8QO2+dLVRhnW/zFfgf1tj84NyIOP3yZmBO7mrta4fd7QoCdvA35xeth3JgaWS2WER1AaGZJQ4VzvC6tqrZYTpAULjLsXkTO7K/wd1L5GK3hgc6WUiaho+R4eTodXcBorofH4tJRdmj4DcQ3kfcqnjS42E2vDD2JOLZ2Pyvo2GM28py52LAfAgaNnATs6L6okrm8npCoTElt3+c8tVBPTU12t4mA9zl6STe7FVsMwP/MmX5xqRQdc7xcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9393!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033833282629"
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
MIIJJwIBAAKCAgEAsGnQn2UJZFShpB4xuA8wFzF1VtGanfjAZ1TGUIq8o/FNuG8R
GJ21AhFWVLPKmYTb9xZEkV2DG2QzcWYdzwm6ss9rJq3nB8VuT3nwg9NRDb3CE12s
wfiGwIYJm4EeeTVTC5/5QCsFg+ghgp5stSsOf4GRaABwCv3YFEBod7GaTfytt+I5
IJK9Jtek4OXMv/pKp228FiDy0+c5dmCQvfGhqWwjEljeNFEsVBVAOaw/gzcIspye
p2kcQzDNfLm1W/tGi8v0WKEgoqhd+1NQeo3w7H9zKZg3+y1ulJ1YzN0slQzcH67X
Z2gs3+Oi9MFHyIPHZ2zflC4jdXV6R05tMIVC5n+2dN3eYHU3S9P+0EFVecrk/39K
ei+OOIZ/72VtOnjk9DuMQY49TafLOlvADPYZ0bX1sorXS4aQVYvl1eIarXHNFijE
OwWu8QO2+dLVRhnW/zFfgf1tj84NyIOP3yZmBO7mrta4fd7QoCdvA35xeth3JgaW
S2WER1AaGZJQ4VzvC6tqrZYTpAULjLsXkTO7K/wd1L5GK3hgc6WUiaho+R4eTodX
cBorofH4tJRdmj4DcQ3kfcqnjS42E2vDD2JOLZ2Pyvo2GM28py52LAfAgaNnATs6
L6okrm8npCoTElt3+c8tVBPTU12t4mA9zl6STe7FVsMwP/MmX5xqRQdc7xcCAwEA
AQKCAgBFBgHUe8nC8cIU3qOBap/cU0Of5n7ilDNjuq2lUcMhOga4xOwhf4MU/geT
OI1qp6sQ8Ct/3OCxVPEzy0qaeSoNUE6SYbRlPAA/JGzQh1vNTpOi1CIF+uFuboNP
zqNHtW96uurhCnQr+iUyYB4UfHY9uUpVMOalxlBHDDRTsK+5F8Y4jlDfx8ouam1e
eUs1Sg7vl2XiGp4n/u5ivMGlL+eazG6kfRTjz2bSt0XbyuNGyb+jctg4lE20lGGy
DU9CX/xoMjK2gsSsH8g1z5FLgkHjprI+cgplQo9jonTeIyOQZemyk8w/72ivaPeX
YBBgCf95HgYUikDhckeXor3iICHeOzhy6jUM5xbx1Ch5FR3hNrgdAJdDuislgGbT
gUqLbhjM2hwBP3FxYwGX4m4kTriiDtO5ZwUrGmJZDuiymUIAif5k7232nuaiKvai
Yb1KCnhGkNO3LY6zvcq5xr2biSvMpTMRc9IvxYDHK/05BQsPq9psPAeUvrZ543Eh
H6VyJW1CcERx4ZgHiPBh44L0JCQ3eHaxXcejhsHg9eG20CUGRmIa4gJoFP+2Dfdv
8Vz73hhiHe+D6TyHpJVhEmOry65at7IGoP/NgjwRMiNxGY7p6LiDUNkY7WQ77wg7
PtsZ2CPHSiEfoHvxy1SOddru+yI5n0nufj+bVNEK0hb95gL6MQKCAQEAx8l9TYiP
fiba2+Lz6V4nl5J3DRwAbECE2xBcS3uZUza9bAHTpr+efO6/+csrppuHM0X1rCDc
ebRsIW64z8gldu6Vi7XF8RgqbV3j1TZY/Xdc2uAehFL4dLVfKoGUMgslTP2iphgU
3P1PB9qSRqmz2ETXec3QJapCwKPTV8OtpGa+hUkLNPUJp1bA/5neNjMRMjlBIpIG
+52Q0b9vLguCF7iNx0LN9ww3kRFrMamkwzi17PXFdZ6k8ZHqflZMRIwm9dYNqz6E
GUjJ+1afVQh0jzftYiChvmQK12JppcUIvGctxy8MgMBgF+Fh/sV6Si5jrrErF3v3
3+J4XyCtfPNBXQKCAQEA4gy7y5kstpJRq2RE/vuCy3WjX/Lj5PrC3odbRZJg5/q9
M3z6UcUJ9DiZF47wowHEfuozFqzUDIuHe+YtICx0ptZyQkGnITIcNfpjR7j3N3dI
9BijGJA+xPbQ4iMYjKbZysQkQvXLTxfbkYyGcL8BLRoV8DOthiTjk0kaUCFmpgda
sQPDBoJT/ed8ARahukxi8Ya2WLQcCYlIiwFS7UIbCrTj85AwkciB8W5yIXXyxfdQ
0eLH+p5kpELSsPTloEhDBAG32OBk0rUK9mqdM3eztYjzIMxNqVRxe37C7BI1b+ME
jzUSdy8fDE9E388Oyus0nPiJwSsCzf7CpertaOYnAwKCAQAZZMjic/sZI8Mps70g
6nDJ2Tn8lpSPLdw1I+03QuyIISsOcWT/iteQNaB9FY/ky1vx7nB9gmfDqGUeEr62
2k+4wDaN3XrdXB74a7irvw6smOFaiKYYV5tw6iTAeFvnyHbjRFHKHsF4HVJQQz3Y
cXWEhauFtd1BDFUTuz7/psWJYe3RbylXf9XMSUCavGn8JZ2H7rMSu9DbZnmjz1tI
VPoiHbkXnKwlPI5LiBVB6LgigDDPf6Wrf5Cji9JsYHetNss08BIos/eCZzgVFDuI
SVzXX1py4IbudjTSj5WyFks39z1gVeCW9NzB7EnSYjNa/m55I9fAUmd9M4HtRXAH
s7uZAoIBAHwq4HEax3vV7bSGlHu3bgYSrVZEFjiuIaKYmWMi38YtbgY9TUbjQ+95
s2ZEZxwzGVtZjAyVjLkDX72IFxuIL9+BBiws4gATBXoE+snn6Sv3gwRKEDSq7z/E
D8NX4eFIuXNuwDhjyXS9tydBGIwP7zZ2ELzrthJsavF5g1GmtzrV6VQ4q8UEi9x5
bh0u8FFkKilfhQQ+kvQOC+IHLSUUXcRIzrn4ZyV9DRuwPlLw9hUWH7faqVyZ6tBr
wE3hh8y+RMmLpBAmWlt/hPEMaSNfSkCaZGqMrtAniVp7q9h+vAmkmtmLHoSHRre9
RyjlFMwT3MeoogqQdK7wlL0MybIIUj8CggEAXH4o1h0IK0djFphbBmckIA8FgOY2
s6aO3C/hFdZwMGtgV9a/MjfAlUxV1rB4nLE5dIDQJqy6UM4OP8xyVToDYMaRFiaG
R/cEHA5PJQo5d6eMG6YKoTkiNTsMSM5KpwuQMP9DTL8uKlqni1Emz7ZzO1cQey4q
tcUnkhPVwla1Cn6djpZ8NdgJ1VUJObKuVQ/X4ueIkHJgeIsSM8p3WxsGCFulhqD8
aIeDbWf+wve1/HpmocA9hk+6hN/sQLnkDOavh1PoDNE/BY7rTJLB26mgQmbJfr07
Ky2ly7AS/PkwZRVbqNXWfTULmrb+I2iXIaDkE+1df4igI2bYPT3VXZbWiQ==
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
  name           = "acctest-kce-240112033833282629"
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
  name       = "acctest-fc-240112033833282629"
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
