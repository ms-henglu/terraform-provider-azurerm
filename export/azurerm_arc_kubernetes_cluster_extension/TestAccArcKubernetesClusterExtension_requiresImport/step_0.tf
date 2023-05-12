

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003423148124"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003423148124"
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
  name                = "acctestpip-230512003423148124"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003423148124"
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
  name                            = "acctestVM-230512003423148124"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4394!"
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
  name                         = "acctest-akcc-230512003423148124"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0a4AoIPa1HodHUxDpNUYZNNQfaZUqFOXGlbE2u6KRGefGCWJUp+1Oo6mg37/yBexamOj0CjzaScuaDceHzi4+MuKnyO6UEPmV5SH9U5Nu4M3aw/2LPZCqv0YpYaL8c9h0scOzQcCAdYvYYwrCdOMHeLMpKQZWhw0P8azjgcajGEnHfTvPrnZhbNt+irleVJBabBVD4fXgNMPzWXIBjK0bT7VRpeio24brYcFkZK0/d42Zn4wqNUZeMDV1uVHE2gBQ9EGJYPV0vPcnEierXVmaiQd4dpg6S7p3pvPYkFNNMzyJeirWo1wqRN+f8fV8CUdB21lSYOp45prH5bV1Cj2p0u42GdlHXdBYUrOkkPCrIbDfNzy8bh98pstWXwsHuMCuno8kytDfZ0dV4TlhGoLlL4LnwzpA25Xju4qCLhOgWZ0TnTOBMv4oO3JurzchmaAhaxx130A1zhULZm43WGKPJD/b+f9V7Lrw8JQOZqKItezpdHuNiE2CzszIGZ+q/6rfgILrtPDc085R7wva4GdfI8kGs/ePHna8UO2BkL06iHaVl8BzaS9IvhExDw+Yv6O4WFl5dNeIfbK7tVFi2X1LglrMuz+afL3GEELOrMz8fykB5ALlqAkv0S90nzPtPFtQxt86UoD1jykt47cJD9gga3aBCpNZAmtCotVPtvEGdkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4394!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003423148124"
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
MIIJKQIBAAKCAgEA0a4AoIPa1HodHUxDpNUYZNNQfaZUqFOXGlbE2u6KRGefGCWJ
Up+1Oo6mg37/yBexamOj0CjzaScuaDceHzi4+MuKnyO6UEPmV5SH9U5Nu4M3aw/2
LPZCqv0YpYaL8c9h0scOzQcCAdYvYYwrCdOMHeLMpKQZWhw0P8azjgcajGEnHfTv
PrnZhbNt+irleVJBabBVD4fXgNMPzWXIBjK0bT7VRpeio24brYcFkZK0/d42Zn4w
qNUZeMDV1uVHE2gBQ9EGJYPV0vPcnEierXVmaiQd4dpg6S7p3pvPYkFNNMzyJeir
Wo1wqRN+f8fV8CUdB21lSYOp45prH5bV1Cj2p0u42GdlHXdBYUrOkkPCrIbDfNzy
8bh98pstWXwsHuMCuno8kytDfZ0dV4TlhGoLlL4LnwzpA25Xju4qCLhOgWZ0TnTO
BMv4oO3JurzchmaAhaxx130A1zhULZm43WGKPJD/b+f9V7Lrw8JQOZqKItezpdHu
NiE2CzszIGZ+q/6rfgILrtPDc085R7wva4GdfI8kGs/ePHna8UO2BkL06iHaVl8B
zaS9IvhExDw+Yv6O4WFl5dNeIfbK7tVFi2X1LglrMuz+afL3GEELOrMz8fykB5AL
lqAkv0S90nzPtPFtQxt86UoD1jykt47cJD9gga3aBCpNZAmtCotVPtvEGdkCAwEA
AQKCAgBvzNeIvsVvha0AcimfOgBHwmSomoeJOQjYgmt0ULxovNeXiGwwIff/wRAI
DS9VAU0X7QjrdOpUpw+XgcwN2bDG98ByGhq9sXagPBJCOf44fT6PV3NrheMGSO1b
VOJJjMocGQdLSvFHCW06FgLcum97f/Kd1uGtqlwxpUEX+bGuKB8zWeY3C+Fv6Lw7
J6QzjChUsjCol0XQ6rkCS8Lbiy2pElelzDRr78nSPKw7cn4O3u0iuSY432c1e5yJ
eLbtIgeKoWkll6XrVRvMOOxikLaK4bcNNeN2cg1BJNLvEOKZxK1YiTbUkZYAkORi
PatU4HUaALqA+DMdqLh1n3dkKHNayUeRSte5uJLj4uM6jheRQmViE27Mr8A1xjjg
HTjmcy4Uf7r1feBeFFPJdUOytV9c4T8PJ2F4rV1a3dfK2MUN2pLxlPQNJhkJRHAu
xuMj4cHJECvqRmtTw0L09Ls8O16V1cfxFv3/K+4r0i4ZPPzSqbEe3zsO0MWDm7kV
gT2I1kgJBzhVVBkTS2eVW7qfw+QPSsQHN1GqLvhwCFAJre0pYitrW7fc2HvpXpEh
TpcLG3RFBZeAtlgpZXae6d9vLgu0QSDuvu0zkcL0aGXpGARf2gGJkQMsd3zLsp+h
gS8pICTz1WBmPLsWqhI2wzOO7l0DI8A7oD0D5re2UMCEGQpAAQKCAQEA3zwYftZN
ImeOHjPHrnZyw2r38gR48ctTntUhvrw08ssuUEvDiBaMZam93+Zv1XvdbM7f+ZiG
JT37brzKSprKXCHlVDf/erTFSeFvriainPBzUIOi3Heyjg/wG29oDmol6zkpPRJq
8IljuDxLw3sksPcXb0cTZLBgp/4N0AQcwgdjEUPiYYu8jYiQHAkg79jxRyzPkwCV
5KIMQW1oKcRPgkQdAttIsgsCAiL9Fj5OdiBoTiPrKedue9OU8S5j2ApVUKVG/ZD2
acgGfT+RpErZJ1UzvHQiOT50sWNp4TAqQAcp4UTs4zUjNbtZTCKCweJNPvlKLxSC
1VEzMTiHmzvc0QKCAQEA8HSVk2SVIpcJoyzcgfEJR6JVJWp8TaLfpFM/jH3z7jDt
Wh7WuQ1S0r/Oj1UPATSfZpmyIm5DCaRMvAILb3YCw8CBN0jgjfANl8PQv89dL/fY
jqYKh4cTcdYdM9pylJHlgIQdplpaKpvfGVxI8/dvVZhkEVlviyR2SZ6s4sOg6Jc3
bfURvz2FQjJaTBsSUQlTnLBdFrSdM3HecHdfSRTFLYAWnJiCA9zIJu8kOFeR0ZQ2
ipv0dxzqWtlPzojnsKacJOz0nDvZwYRbhx6FcJHyofUDg8qUUuessJL+Z3UItJPm
obCEKKxUg1R/ZKRmKi6ao9W2dh5byQVbgoBuZA+OiQKCAQEA2EMd7/Koc0YjNjsv
nWJ+t7ZvUfTnPkeeUOdlc6RdH0GbMorTeIlvpiWVHs3dVdJTps+bx+/tNTMg3Bzl
VPU0SaFEzBwb0sJBxtsxGGOxcZy3+i4snq0PO/VQxSNeiWhoJ8MOom2vUCupgZhY
RZ6M4yvddh5DOW5tlRHYS8dQHOCPJvC+5YU8O1krUx283N8sj6lnxp/wlrgua0wU
dzIJXMej21qYyHNFlNBUozHlTScEJX9CmSvtquRFDInGjEsmb6ROa+P99GilcL0e
2SzxxtsR7eYMKazJ2/fVYSUKKVFHT0c4vryBydIgJlPgnPghoXpcVdPnE8VAdNSw
+sA5oQKCAQBeRXb3CHIn04tlvArfrv5yZUR4nN0LGxYPOMwrap4d/nSv5nNMrdqQ
4b48F58AW/86nHtoYE5ME2w6MZsGIgBHesuuPxY6z6iknZLUAJqKWeM/Wf260Mxg
zw836ycM9H5D+ogdVkMPfXjkWngHnjS6HDrvSl8e8Dan+lvRs9z8E30Z0QEaNyZt
o4wfVmXB+6QaRFLaugj/yF7rPQHQhyIfCp7S2j/u/7pA+XT72elDf5Y6lZYstNt0
rspJMQeVDF0fZP8p2ZUv95Ji0SaD0dSMhqDQJLYuIsJjn9259fppwaqkLa5Cu/2O
V6xyarnbQ9ZA8WLNwG0/zKfp7CxbcnXxAoIBAQCojs2Fw+YMttFY6/54hlvRGDzh
g6LKTaHQ2tBYZk2N99XAIHm5VPTmGZPdfaWLUKTPh6npAPn80RbAys6hsXk63MzL
pVc3hcpmq9uqPDWb2vhvL6cU0janJcPK6B2a/oLVXFpKV8KX3GV2/AEtlsTqRJ65
zlv6rxwq8RMRkj1/WuyU5EehmYj81Notu3C8rdcoLvQEa+m3FT7dWrRg9zSvRe47
A9nf/kP4Kp/HsvLsKA8CUDIQ+E5rnTiGmJN8y+Ajt2GBXuwS54R4kC34Xoho1e7f
Ff0Su1YFUvhK6vmzo99kvgnOMHnaGIG/okXeUl72fnqhO48ErtXrtzZV//tv
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
  name           = "acctest-kce-230512003423148124"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
