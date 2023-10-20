
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040533639695"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040533639695"
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
  name                = "acctestpip-231020040533639695"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040533639695"
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
  name                            = "acctestVM-231020040533639695"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3663!"
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
  name                         = "acctest-akcc-231020040533639695"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzW4rjMPaXjIj47xp4mP/+ryW20y11EiimFiEdLXz6RLmmYg30npQ+l8Ds4Sv7wzeSbdSxwSLD4ku7rS9LARZ2gLtnVfrpgbxQAhmd5jOPXxLG2wMVpOzV7NvPWxshCbHfCjzdzYilV46xAstCnyFHRnvdAXGRXCeDGkO+ZH10G6ZAnluprBkmLJ2po+7tol9zTeCCK4Z+piQolGqz2waelcYI6I32DxhFE+Ky+8kBlNu6BA4AOQbXm3Q5BMa/IiVyuVIyxojkNuvQZOZEz4gUy5NnipNDwbedJRfqK+bQaBR8VbCbD3qP2oIC2fAoxUbDoFJNfUJzFrCjDzJoJWE3FbkSaamQHy9do/Bk91gqWxop8vK3gpBc2DwKvKRvRf0L5WAxqL8fWML/igJmSPAnNe1A6l7NLlC/xtC6EZy9yFETY3e3vKdQbP0kgS8GXPWqFUH60yXQOqMLz4rakvxS/qzD8RjMAkyVONgirnvU9YChr8trFt58OcxE+xknEf5Snvq4fOpcFJyXWRJV8jgK7GB0Ub0Tpg8DYZPIcIaWzKfX1K97F4m+5ktUI3i3QZaJV8Kv/cpcdvNVaNKXgQZLotZguYiUTIF8Sbk/BFDsNt8lEMM3MyxXxr9KpXrAI53tAKRnVDxc6YVf1cj3e+Qf92wZdtNWD0MpAGSzDTrRpUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3663!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040533639695"
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
MIIJKQIBAAKCAgEAzW4rjMPaXjIj47xp4mP/+ryW20y11EiimFiEdLXz6RLmmYg3
0npQ+l8Ds4Sv7wzeSbdSxwSLD4ku7rS9LARZ2gLtnVfrpgbxQAhmd5jOPXxLG2wM
VpOzV7NvPWxshCbHfCjzdzYilV46xAstCnyFHRnvdAXGRXCeDGkO+ZH10G6ZAnlu
prBkmLJ2po+7tol9zTeCCK4Z+piQolGqz2waelcYI6I32DxhFE+Ky+8kBlNu6BA4
AOQbXm3Q5BMa/IiVyuVIyxojkNuvQZOZEz4gUy5NnipNDwbedJRfqK+bQaBR8VbC
bD3qP2oIC2fAoxUbDoFJNfUJzFrCjDzJoJWE3FbkSaamQHy9do/Bk91gqWxop8vK
3gpBc2DwKvKRvRf0L5WAxqL8fWML/igJmSPAnNe1A6l7NLlC/xtC6EZy9yFETY3e
3vKdQbP0kgS8GXPWqFUH60yXQOqMLz4rakvxS/qzD8RjMAkyVONgirnvU9YChr8t
rFt58OcxE+xknEf5Snvq4fOpcFJyXWRJV8jgK7GB0Ub0Tpg8DYZPIcIaWzKfX1K9
7F4m+5ktUI3i3QZaJV8Kv/cpcdvNVaNKXgQZLotZguYiUTIF8Sbk/BFDsNt8lEMM
3MyxXxr9KpXrAI53tAKRnVDxc6YVf1cj3e+Qf92wZdtNWD0MpAGSzDTrRpUCAwEA
AQKCAgAaMhNBlvPwkQo8jxkdck0BBy1hd420LTL2pEr3qwAYV32qVFFx+ID8/EK3
kJLys7xgwAzBLhYhfAfNDqUUyNVAVKFCMCTvffEjji6qz4R1GLVnIMcN/zWeWFY2
Ce5oh51mer5ZFEEitOpfd2Fd9fTvehArxlS7JBozUO5E6tTiqEfApgVzIgkh45f3
s1pnc27kTVC6lKDhcLT4zdsvKgTSVurQGG5wl3p1oZL8YFlCqT76Pp81leDbkLtT
ahBF5ZDcV5KJu6KPZUQa45xgdMqgcMYbBh/fa6vQR99O3l24552rXbnbHaYSQg4W
jjtlUFqr5daVF9MRCP3H7jRz0r0nNR/R5TXG1Ev9YjWB1UTmmS/IQ7U561DeJ+CL
f54FY0c7pz5fv7PUORkJOlNBCW/I4Ty/fprPu0NIIbk5AFkJijHPnXikMkeBO/eT
xRkGe2Npsb0+xS2sE/bsg+3IUlbsZIu6XDU7qqOxZmDU9Vfgg0tetJbOQmtXnWl5
p+59y9i9kivmATm9687kqMSIHICX1s2PMmdXrc6s12I4yzs9TjfrP0Af3hbMyLnG
aKUibh1mf8YyE2qDf7pIKxrM6VSMtRRyQ1Jr658r9DyV7BKmWT2GTcZUxeimMnXI
Fw0hz3M19vScN0Ql/Ncf6NAMuEuz5KpJtKEjeHz1D4OrdfqJwQKCAQEA13lM9IHF
EKBAJBHULJH5Nxpgjt5f0DVf+dOK6Ce5GnnM6s0LWa5E0RSg2Zfb5v/J55Xs9e2R
oG9/ErO8kjetqkm5g+y9nQyxcbPLK9iqtejbvm0wSFhTFI8Tg6Ls6hVJaggXEeaL
VyxXJu8+M5q9FFClo8IHf6zNLb4I0UMocm2VRLhfeUQZwru3tT4YJg1WthHN4xIB
r1BY8xng9RxyY7mw5/CK1mr9UJSE7A0La+mtfaH/3ZRbSMi1Exbmwf+nLy3UuJpK
ZEYSj8743LH0S8W+ibu3r3HXSlcWMWGrZC29ZeypOvvt0c1dQeGl7qgPwD0Q03yM
nrylPkRxasJFpQKCAQEA9BFLBgaVRjoEc78QYoR/zi71IGOyj9tTATR6DQCD714s
rUY/3ReS8JVruTdXdA0e/8FzqWeE86r9wEj/umsT8RoTKDvnl+zIo8N+7k6hXZdh
hXOoaMznuG2ESJmTR/eOqoS2tzeCLQjWvPTLzKs5Mrv1JHEKPze18Xlxj5fD9bGm
PSAvjP9ywe04jHvro6jiilvjKla0C+xj2vLV2NiFTFUcI7ESjUIrc38e8Om6WF5/
oBQOAvUIiXegbc0XAVuqDEZpmQBoJ3CqYQhoFx0K5LGr/hloIcTXlHx2k5zRywUG
wBmJlCAQcaPbI5DGrnYryswQiaSemW3A7lqMHp2KMQKCAQBQQ/pbtp+PIvLhvNZ5
x+K7GRNRBRtR9yAKczfyZSG58BdafAk3Xgh6jiGhDMW41h4DK8E6l0XBKud+MwAS
w7Tok1ANCbpUb28GOQB9E9f7rYN1+zyaJnTEWsvdJGr2g/l2Cw909pl/XqAUe9iC
5qh6kdQyHUwnzlocKQcl1MuTXKjXEYtXI/wooz66wCfEvQFJD3bPmFySTu7jmAdJ
p1AhQAHbVKqTVwWH59tgBzfy+fhLrXYft20Nvt5c/xH0wGQp2fu8zJTbp5KwiVwA
8jVbqIzix8+UBmc5ZRl6SbTLu5IrDq63rzMXDVYo/YKPVYGQje7fqSzE0OcJO/u3
1iiVAoIBAQDsOnCq/GQu/KiifyOUtzocjkajetuxcU79s5UOUJlibXxAmeXmUJLg
WT9SncX/hVOjp9IS/Scp0S6Zlg4umMVMbzhrkM+vtHbeSrHoZiK5O3QgfrlZ9jmx
wA5xVnO/DFUBpkJTQ16zyAJQEX/QMUnDWTkEdIS+e2WWuzy3BuWcQL3uG+DqT7T7
DmfVUXvZg/UAhb9xk0ng4IQlvzRMFgWuxBHgWdri7lCwETIZa5/5OD2+6qpFInWI
2Ehm/kJuBhKont5GQKaOxfWixUg6VtncUDtwTZcEWElwZqc+aGKGZe8Kr60Buacw
1q+b1Nz4r1fjiW/YSYVYa2p5SRql50WBAoIBAQCVZxeX3jc6fNJOMmbWBQVQwHD2
xDvcDEayy2IxzzAnioTZju5Ry7t71FgFJngmIC33A4JgHvRLCZE6/jOOmiIUHjCo
C8ew3pkT3e2E6zG3ZZ3m5oD2a4V/pawOYj2Z1x/PHGvPAb7ppMxp4/l8JJcep66O
vmhHXZ26JpLs1C3N9J9PlcCnF7QR7xN7ofmn2iad8IroH3Z2/cAgpIym1Mzd9pwf
LE0/XmDa0zYDo2YORm14l6rE6l9JgpIa+LpH5GzJItwDjd80nwzXgGTVDnFSw1vL
NnsMmlChT8P+awHWT2djOAOkseBQ+vitaQC8pUKumPgLjfbT45eUdv+Dcvoz
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
