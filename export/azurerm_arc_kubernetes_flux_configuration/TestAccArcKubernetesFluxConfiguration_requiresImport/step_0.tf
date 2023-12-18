
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071237694824"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071237694824"
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
  name                = "acctestpip-231218071237694824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071237694824"
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
  name                            = "acctestVM-231218071237694824"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7154!"
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
  name                         = "acctest-akcc-231218071237694824"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv4jDJ1LkahnJH5YUfImKpYSBStYbsLwXsRHlMlofasMCO0ssAH4fPLIACGZvlVV/h5OfYRWmByfWTanodXOo6tEifBHAlTRJvDWNG4fWtyuqIa1tdhoYGD+Ao6EPdOSAesnvEMl6Ahk22YtNulQqtwPMY2vqW7lkSpcKyJPpkVdV9nth+yjtkX9v7voU7aUz0kt6QpazweXvWMoOGfbBVpVy7nb2o88nnJeg8GC9oudw/BlXw4owxJ9M0iImnhMrI1uDv9aw7mA1mUN8HLLc4Wf9sPdETE+0q4tmPG3CSkZ13BfV6S1M2v2MCtFUFJivFcfZ0/cgOXsRahNTtzlkowSrRG0U1axierKd2GH92FTBT/rWsSSWfXDIaWJj5OsefbRkZU92jvBGWn/KFTUCeYtEOYNxdvvCFEGz86czPMeF5TaUHMaNdLnBWG76tca/tSkNECwwqu91pf7WamNCdi19I/NejKEeQNgju952Rukb00F+u9V0vaH9doVR3wkTCLpG5mJ/7+d2W+bM4P0f2OKE/9YzlqIPvfO9lnzYbg7kioJFaKL0aUIZep53Sg2Ly27201k96rAHj9jRqU++Y9kPX8B+xBRwbIxtdSwwLF4VFOaVS1/8R3MrIZ5hhT4Bamiivoxibm318rk5/abgNOFL2aLl8X+0rxGWZledM28CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7154!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071237694824"
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
MIIJKQIBAAKCAgEAv4jDJ1LkahnJH5YUfImKpYSBStYbsLwXsRHlMlofasMCO0ss
AH4fPLIACGZvlVV/h5OfYRWmByfWTanodXOo6tEifBHAlTRJvDWNG4fWtyuqIa1t
dhoYGD+Ao6EPdOSAesnvEMl6Ahk22YtNulQqtwPMY2vqW7lkSpcKyJPpkVdV9nth
+yjtkX9v7voU7aUz0kt6QpazweXvWMoOGfbBVpVy7nb2o88nnJeg8GC9oudw/BlX
w4owxJ9M0iImnhMrI1uDv9aw7mA1mUN8HLLc4Wf9sPdETE+0q4tmPG3CSkZ13BfV
6S1M2v2MCtFUFJivFcfZ0/cgOXsRahNTtzlkowSrRG0U1axierKd2GH92FTBT/rW
sSSWfXDIaWJj5OsefbRkZU92jvBGWn/KFTUCeYtEOYNxdvvCFEGz86czPMeF5TaU
HMaNdLnBWG76tca/tSkNECwwqu91pf7WamNCdi19I/NejKEeQNgju952Rukb00F+
u9V0vaH9doVR3wkTCLpG5mJ/7+d2W+bM4P0f2OKE/9YzlqIPvfO9lnzYbg7kioJF
aKL0aUIZep53Sg2Ly27201k96rAHj9jRqU++Y9kPX8B+xBRwbIxtdSwwLF4VFOaV
S1/8R3MrIZ5hhT4Bamiivoxibm318rk5/abgNOFL2aLl8X+0rxGWZledM28CAwEA
AQKCAgB6Up7IO4FTXbp8KL5WtwTMJq7oG4u9uLKszJADM1mDNp3zPlQQ0HukqM2q
j7lNtzfmX1pXh5rsUP3lxdCHSmGj7gLHGBNVdvpscAr5fSyc+Q8DyR3yYkHnIo9G
cXNMpS6EvPioUPRR6MaF8ximGmDZV1yuVlprUCCEHqitZwGxaASnkS8HV6E53hif
mCnLiElrUfb4FgUhnXbZztlorZXWdUXclC96eK+Eq7YGLtKN+p/G8WyCnnv85vwJ
6/Ob2wQe5bBj0XpYEyvIATh/n5+/eUmlPpXo4rKxKCsYBsUh6JQXB0X/UIYYCfvp
YL0BFm4jS+qLG/YBn96ET2mUx9vDwgn0WgnCPSK+rNvxhcSRZ0FKNQvMgGrRXBtV
A0DiWIimKthdURgSyRgbva+DhSnsJ1apUqqD4f3L+WknXRumTOsLQNcN5WA7NmKs
O1G/Wo24p2U6hGXuQgpyf8fE0ximeMI+ypwjPgqhuYu1wQYNlPDePwm1UVML/wMa
DKiaUtQT4qd42BdIkVQuOjDtLuiz3oAT3o6f4Tq34HeTdeUC2IhyCasjBixEvS0S
uQYz0ir/sDP9Fnano9R+j6gHSbbmmYSJIL2K7pmF8NqarOi4S879VQ02IZ7VPX6f
t/8fODpjq2NnNXmkrkVa/2ZmI+Yoou4yf2r332ypWJRZmgv8WQKCAQEA1TnVYX6t
2/KeWfJrd30StYhVck/+a1DJBLMrgERe/YeJAMlJZmLPH1dxHcSA8IXuHCcaeOU+
5NqgSS2phkI+wDr5ZmCMmJ9bZ5osma/OuN3LrmhgPomRtjrzvfNFcaTwFgpg13yG
XcTvCkm7WQM8P9YGiGilCEz1jgmuJau/NMA/jHmnJVPb7icmk+onPlwT1+cwvK8N
uAiIHmAZRsAaHYYM3JjH0fKkzT7o8kEEf5M2Llbic6IfGWWrnsXUUAb4pp1MoOge
/3Kgnvr9l8YW74E8hMG2Rm2l3FJchzcuZJAYP9iiGcPpe6DZwfAv8UQRGUsNCEKi
xEC95dZEsxqlNQKCAQEA5fT1HBNX5tEZhLjRZCHdCuWRLVM+eAb1XblB1LRZRrFX
+R1xASYTGfzVXxcrJdD/Uaol6fqoo7d+sQYLEUVtEtN0maKy7587JY2ifZDbd8+n
R/OhrGN0KWPFOyq21PgzjhUz+ZISiAlM+7vaSiJYSj8Iq4IdKxaP4vpgMfrwnugk
kjSkFPsYH4USVgEJMpdAByL1sjQPLNbtWO/7ewYBQKXC3YDa9nSe759VL/7T8Od2
1zeuCtpF796CICh/7ZeyiSAw7TwKCBO1S3IwSl4NNVUzX/hMOwnNnm6O3w+guHc2
LBkWg/8mkNAjebFRzW/59pSGYODayclPNuiaK0e+kwKCAQEAnUJFNN2oPnLHBVG8
nujY9pfxZRjIbL+tMlEugTBr2pKuoazS/LddSSFFpQ27hylP/uV8KbPx2fnAg5gw
0ntjKoWUUUReDWZilJtpz4ORdFjokt4aNaVimUMLZ4nXKsTZ6XeICwWlV90Z672L
dk/jjLU+Jjb/mIqiBDrxfIkZwT8U33cNpoMdzpyDYE4u2VgxrmetU0vMU3G/ap+3
pK2j1Sh7rerkXNyXXWTLi3gWaDzblfuwklX8l8+bbsM7Hja2BrQ2wunPitkwy3AT
vm9zlPr89nCkDXdq/36jDXrONY7sw5HzpAsQ1YRBdj6+LTPlZIEswG3c+98/7xZD
ntDFDQKCAQBWTJbMIYpEikaMY5vZe0fsNflEzE/OVbYxpTvKaqBygk2kpOLq7nIO
t68Pz68WsxeOe09dPv+Y6V03bDAtHCPyA79nhQKoINbeogfQHdPvY9PAkfMjsfM/
MT0sljwlMryOXvCxgZtIyEzG0Fn8pmUCACPt0ZfGuuHm6dW+DBHPYQmQgQbvBMip
05PtCNh9zvttcjZI2Xa0ejh6vx1erwM7UroNzLTf9yZKgT5EE9tQNl2IKVI8qmvC
uHuXO/u+m8aZ5aXW8khFfbf1B3aOAjvsvvvX0WQyZ9xtz8n4dnH3qG2BIS0s/k1n
3WTi36P2eEaTvmur4dbaEZ2T2rk48uTXAoIBAQCJxNmHHVEhPJcgKPP+E0024FyK
uuUkUntjnLtpHO7aRhZhUQPu4bt1l8BTcA2CgJRMD/I02iwKBq8g+pFzDYECII+O
yh9jg4+BRmoLmnbi0jacn0cZA/Gx1WPiFzKJJMGvx6BD9GvbJPuFXZ2EV3oYO7p7
ZEJxNCNcdrFEQ+D6wPA0gZ0Qc+/c4UV7aP7UdVqmUDO25kulrLUxI7gxopx1PUgZ
sQfkzvKQy2yEwaAsQs3dzay+WYOHfSOhpRzNlbkRBZ15mCRxlmmkWlrwEAZiuyZH
/AERjnVQYEFEI9ZV/iGU7+ZajrMzhGXGs+Do0v303kMlAkdiVUIvMGQ0mPoO
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
  name           = "acctest-kce-231218071237694824"
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
  name       = "acctest-fc-231218071237694824"
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
