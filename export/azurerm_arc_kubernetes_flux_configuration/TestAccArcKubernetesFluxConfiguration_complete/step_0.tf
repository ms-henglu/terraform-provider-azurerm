
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022911482239"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022911482239"
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
  name                = "acctestpip-230915022911482239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022911482239"
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
  name                            = "acctestVM-230915022911482239"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7233!"
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
  name                         = "acctest-akcc-230915022911482239"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAysG0eRvedTx6ZMZUhLKl2k3Q9xsGZdi0bqRWtrPWJBoDz0W3oB+dMGxfx5PCuhYH/UntuLgsMfh54LwQu5x9G+wIO9i8LKfWMm0BLzeQs3LmZANae7e5lu7ccNF24dIGb0m3vyNt0h/z6uXepTlZFz6YcfWmKHzEOxbbnBj43vTqPHAhSEagT+t/hIZLo2JTcY0QqCeY/VP/hopXf98n0jt1cqb7/23871Ju3riBO0xvW66fpbyBQgmP05X+8kBDigz6I//jOi3zucUbsSm9nQynkA1JiGCcJAKtQYgHBaHGsXfVFF6R7mX1OL6MeuuRVhQYrwuebboZf2mDaiURSSpvN0Hd8H20FJt0Ehk+jeHqb1NjJSrHBKgbwTgC1Uh43bCeqSHwrmioo7Ym3O/2ADm/bFExzzb7+mUlA2CmlIJleI4HhKIfMvyMEemacM6y2rHPDDAUs5vKZcg3dmk/iYeQwIFo3w3zbc0FlegENS1LTmrHfA9GfhxoqyMglGc/dmLove/ej6+4D7gnQlwSfksID64S66sfwm+YcTjvK6sJkU3TcG6/hzz4cRaUfi5+VtptMWfoczayKXSRaI39LBQ7x3vhLEPbZ3ukMNG5xAAbXkoUKXRPz7GyysIc83xOQIi/Ixt2bEt9LKGhvixJvdQoowM5FHLbhE4NPGH6GEECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7233!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022911482239"
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
MIIJJwIBAAKCAgEAysG0eRvedTx6ZMZUhLKl2k3Q9xsGZdi0bqRWtrPWJBoDz0W3
oB+dMGxfx5PCuhYH/UntuLgsMfh54LwQu5x9G+wIO9i8LKfWMm0BLzeQs3LmZANa
e7e5lu7ccNF24dIGb0m3vyNt0h/z6uXepTlZFz6YcfWmKHzEOxbbnBj43vTqPHAh
SEagT+t/hIZLo2JTcY0QqCeY/VP/hopXf98n0jt1cqb7/23871Ju3riBO0xvW66f
pbyBQgmP05X+8kBDigz6I//jOi3zucUbsSm9nQynkA1JiGCcJAKtQYgHBaHGsXfV
FF6R7mX1OL6MeuuRVhQYrwuebboZf2mDaiURSSpvN0Hd8H20FJt0Ehk+jeHqb1Nj
JSrHBKgbwTgC1Uh43bCeqSHwrmioo7Ym3O/2ADm/bFExzzb7+mUlA2CmlIJleI4H
hKIfMvyMEemacM6y2rHPDDAUs5vKZcg3dmk/iYeQwIFo3w3zbc0FlegENS1LTmrH
fA9GfhxoqyMglGc/dmLove/ej6+4D7gnQlwSfksID64S66sfwm+YcTjvK6sJkU3T
cG6/hzz4cRaUfi5+VtptMWfoczayKXSRaI39LBQ7x3vhLEPbZ3ukMNG5xAAbXkoU
KXRPz7GyysIc83xOQIi/Ixt2bEt9LKGhvixJvdQoowM5FHLbhE4NPGH6GEECAwEA
AQKCAgAsjnjcjHVMiifTcYotRx0PZj5frz6urvqnvdGYgNi0QktIB2gc9hWTCJ3b
u+r0/dZvoQluqHp92L7f1jRPJkqQEkSU8kIYBiIaHr495BYWeU+L9vixa2SLeJ5U
5JMdeQwU9Lw+csi1fnQZ0L4mzP15EDZsBLGpABIXciR8nzhBtsyqz3Fg8rRUG8qA
EwsYMoln0LoyWdFTClyC8m/cF+wmVQ6wTWXfcgo9hX37z8wGffuSyEMpJs2492T1
+GZ4UgsFkWh+9MK4jFSdJGW7fxK+KoPAMktQfvqRJ01vszbn0+9YHJ9kxIuJOjqz
Z5xzfsUHh48NGJ6OOnFUAJnyf4bWivJnE684pF/CIqrASXuSHCxSDtxRddQzrK6P
1IUWbNHM7Y0TGiGRPJhiWsBE2z6I0WIdevoNY/qaujXLYtj5O0UUCseKpHSduLAe
LGcV+KwAGZpX8OQlClCo1QaqdTQmv9BfBjkZG1vv34mM5m3oIvSX+EKyWZRW2f4z
SZawcERDeeA5Wc8y4igQQp7HU1EnPr/LlMM4szN4FO17cVea/jAv++rZlXWmtMdg
iLikJ/78p5kYS3q4gfjuLt1Jvj36Ct17440DoNiIJWwi+00FRUbMBSCxLjnmwirB
sch2NZH8BtMryZB0WFGPnd026YMykKM+2J62fIKdx3OhCABUqQKCAQEA87DIrcsn
XcE21QnoaueJqAlZyB1zVFdu+2YYkYdbOxGu1BU6/bfpumZo7th0BKax9rMTeNm6
oWshviHL+vg4HNjP4uxyoGy00Ci6mT+9EDJ/Y5uv8nf/6nmhm+x5VHIA05lTZunJ
N75BPTBvL0qMV2WR7R/5lVBaQ9G+VWDcA0E+rM5Ppm1zx/HNBGCm8NIoe1huxpbK
pE6e3ntr8jIiHdl8TW3Ku3ORt3F9UsjK4pGZkCF2fV97AWsZhcwqwds1jM8QQrC0
cXFZ7H+fV6uv2KbuQooiF87OIQG30eN60gbGTdaBpPeg9oAt5A5/m2N2n+tRZiJC
WcheMocBsWq74wKCAQEA1P+Yhs7FgX4SzxvdB5wrcWbSS/xG5hWLNQGoKz9hIg3Q
M6LEJw3Mf7rM6C31h9B+3G68Xg7pJA2Cf68ukbjPt/NFKivKFnjTnShPza7zUB4C
iunHVS4/U8mC6F1XhjvrZGJiEn7QFAwXWPPlD1kF2y5011YxzqF8gN4TGHDwiyhH
UMoQihAmcJeKJZcl4wxiwODlVEqCiNKS3mh87M/xvHwWEPLmE7k9HOZ0ELTTYzCq
Qp8QDLd4UfoXppyz8ME5huZbRWcWoQgX57refUpBedMM4U9CExu0dGbq+EqtkFv/
UTaVFAQKIt0SX+uJ0FHjc7NkPpp7A0M+YytacWXciwKCAQA+4o/myVYPS5zqvPPN
IpLTWhZhHbh1O1rYZTBR3awdQiLrd88RSjR2dZb+i7zktl+WWf/cX9NZdFvwxKfu
y78vMoPy+zFZVLQUQ25jvZ78XwugmLx+xZi02U5q/ksRD5pHAHoVRJ84U1Biie0n
NwWgSAWwO2Act++TMLz9K1GbRWr3DQZg3D3UiwFs78QkwRbRPbDYbnE8lU1J/G+O
wIEtUsJQ+NQoK1qfDBpbEpXIgeou13PMRqdnZkvfyx/9hqP7AjQgAZmO7MFX1lc4
OIXYUruJUDwcCLIIsnjNIPbA3B6wV3p9J6nR8qHlCBjF8JTcD82hnZWhtaMZRt2Y
+wIhAoIBAE41i8v0IJFruXxSvtYMgech2hYMi/vv7S2JbjZzDzdx2wEawuuUJYLB
FHwsY/t6kxpdjsz6rKCQVVqM+IyJT7w7lynk6k9WDl2mb6cWlkDUxBo9vPOKB7a8
R1UK8RhY6BX0Cg7Agabaybff1jvMdFoGtOBcxe0ZXp3y7RAMaEawg38msuv/Ah5V
hmRHG6JC6f/olExfD48twr/nnfdWY2zSI0gV6GVVnxr9g6CexP+m3t2Xik0hEQ0I
x6Zl46yDRpxB+UGCmMyILD7qXseifGg/Fnuknp5ljd0v7Rc+VHytSxKG+DZhRVeH
1TdjRTc42kuhky1pi8Gm70F6qbr5rAECggEADLKWQ85uyHLjXQ56dO/mriL5b0ph
iRswdoqW7VyDlL6lKljPqaMQH8xs8uvSUn1Qz7zYC3p3VjMBS2OTkM6q2a5sStqo
L5CQq7fZmPnNC6/GeB2IZw1whcqw1dwjcU708IxCWs65TFNbGaC1c5oOlvF22iJi
wtaM5jFDuCGtN0HHIl+bQd12C76tnvv6MC3Zu4TtLyfm6idj6w3NSsJ0YoxmhWzG
CHzmtZfArVhmMS6mpytBPHjFELUgpYMbcvWwuUgMEU+uEe1OHrvF1VVy/fiFsSI6
hXtgUIaXbfDnMdf16jnNIE/dG+BdappY2E+bFKu1UKDB6K7STue2MyGkeQ==
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
  name           = "acctest-kce-230915022911482239"
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
  name       = "acctest-fc-230915022911482239"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
