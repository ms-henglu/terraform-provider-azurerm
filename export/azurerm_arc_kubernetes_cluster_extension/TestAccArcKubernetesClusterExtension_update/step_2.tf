
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084606888856"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084606888856"
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
  name                = "acctestpip-230526084606888856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084606888856"
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
  name                            = "acctestVM-230526084606888856"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5154!"
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
  name                         = "acctest-akcc-230526084606888856"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0EZOZy0sIPDQZm9xH+COHhPzJmmRGPsMNXLAdhRFhZZ7R62W8ItEk6+/UIUiJvCV+ICKpB6ec5kY4nBpRRXTJ5+8bNi+bC7EPVNOBsSKoYg+jkJK4UNujW6oGnbCw0UA1d2uXPBiGjh+c2cNrF2p4/KeZX2F2ksIk8i3Louq6eV4RJ5wukNaKBxwLiBYwIpcCKtHDfqaw3RsE29GTS0t7ccLZsU6MLq60MA4khyoEFw+st805TDeFnUb2ctM9i6J1MnuXEcsloo+OkrzKhEV64/mxuwOJG9jCIiZ5iV620p5ayNppMbGsO0fkrMc/bw4jH8x7M7aO26fAiHT2GABHGI8L/7K4k9g+o4IW7ivxkLxoE9dmLXFL7rbU6AiQlNuy8/rk3kSlBRmmdRdxt62y4mc/nmhO9VW2s/+e3KQoSChzVvBUYz7HYh99splbZXkP+t4cd1ijpvXMDpq9x9QvejGbC2UcCB8rG0Ec+AbhXxjqpENWFEBkd7LD1WzXUwcPukI+7zFmevTrmzFwisDdWtbgX870gE25ZHaA6XUt197Od1pseK7fxQyHJvSLm2XLekTYDZjvOhhUMBiL/hBch/om/tsGm5nP80smOnTbBByDUf9p3VJSrHtkOCTeaUUck1BzWxOXsyTtc62NyoFKyPQaq25ye8FlkXF926OVmkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5154!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084606888856"
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
MIIJKAIBAAKCAgEA0EZOZy0sIPDQZm9xH+COHhPzJmmRGPsMNXLAdhRFhZZ7R62W
8ItEk6+/UIUiJvCV+ICKpB6ec5kY4nBpRRXTJ5+8bNi+bC7EPVNOBsSKoYg+jkJK
4UNujW6oGnbCw0UA1d2uXPBiGjh+c2cNrF2p4/KeZX2F2ksIk8i3Louq6eV4RJ5w
ukNaKBxwLiBYwIpcCKtHDfqaw3RsE29GTS0t7ccLZsU6MLq60MA4khyoEFw+st80
5TDeFnUb2ctM9i6J1MnuXEcsloo+OkrzKhEV64/mxuwOJG9jCIiZ5iV620p5ayNp
pMbGsO0fkrMc/bw4jH8x7M7aO26fAiHT2GABHGI8L/7K4k9g+o4IW7ivxkLxoE9d
mLXFL7rbU6AiQlNuy8/rk3kSlBRmmdRdxt62y4mc/nmhO9VW2s/+e3KQoSChzVvB
UYz7HYh99splbZXkP+t4cd1ijpvXMDpq9x9QvejGbC2UcCB8rG0Ec+AbhXxjqpEN
WFEBkd7LD1WzXUwcPukI+7zFmevTrmzFwisDdWtbgX870gE25ZHaA6XUt197Od1p
seK7fxQyHJvSLm2XLekTYDZjvOhhUMBiL/hBch/om/tsGm5nP80smOnTbBByDUf9
p3VJSrHtkOCTeaUUck1BzWxOXsyTtc62NyoFKyPQaq25ye8FlkXF926OVmkCAwEA
AQKCAgAcVBPB8OD5sgeGh03pug9ag/gkl2NG9I6ajnsjFGrIWsl13GSVXzv6ooLx
HsqgZUTgwgsZe5itvHsoAYYwAWHxF8b3PxvXdxz2AmiwfvckNXXcv6OTtCpLTmvK
/bBMAwy0Ciz3MzMEwf5hD/lKIotDF/L3dvVH1cDa6QgRaqnamn2bR7mpfBO9NPEF
NR0dQzR1cWZ+vkFiqGky04XKZYTDvLkOR3E8w4k5b4vCQ+eQIhvdFIMLUXRDtbYO
D5ruOTJCIR0sq/mimDcSkrM0W5KRscb/84eQ6R2dQYc9SIfHX//X1L8/zFGmKvqK
Z5Zf5MQESCCwRwpj3w39qkA4RAaiaNX0DHuF9h2Ydb8hliqPxYXNNJhW+NrpeGu5
ygZuNfNFtwttjOyTwPy3o7oinBao4xNyqKtr7IEtzLqujUPFIINZEwGH/exGBqU4
FvUUjPsL4l1DecbS3UAfBhnYYveEyEM/GpjLXlHm5Cqhysy6Y44QX7ZL4FDkSzds
MpKvMx69Hpv0RhEHpr85B9FY8j3hrmFm42ywDpdUz9AE2d6tD9TA3ZCC31w5JRk+
F5IRDbzU6FMHxRzMi7AzQMhltxZ3Pp/j+GzX9PMoPUVln8mw6dRvctXTgXtX53kX
04jC0ZjI4t2CDHVepwqr2ywj9JMSWjEF6yKQ8NVtmvNC9SAGIQKCAQEA799fExlV
YRs9c6SEd1gRj5gnesYSUyJP3OPxrMl2h5UP/k1XSYIX3YF5TTWsybN1bwz1EcGl
/AgDT2sTzmvujXH4Xi8GL0C+WwlLpudrexcS9s2FZihSS9KcDjFKRWmNb7fSVvLQ
/hf5pdxPSxS9khc9iBU8meqplXRbdTtMMTlUFdF3l+DLypzrp05LAfkVJERonEXQ
UIt8LoIeyMCxWOIYSx6qiwOY5Ks7H/CFm4GyoZ3/P+HSzswWKz5Qa+mxRuSXX1Mc
JnYXIuTMFab/uC+9gGx5OdSRERdCzH4E6B33VIy8AusIsOgpVNpecrVwiMnD91CR
VsqQ5Wi18BUTXQKCAQEA3kcUSFpY5wxIz4DATOIh8dqg6Rw38s7rfReKrluaj6ut
n2J7lkJoaTJrlhjQU1qdGrmvzKye+8vgAXPG/UcIuTJttRFRaarddO4SHpOPvpFq
X6QmkBbkml8XwZiMYCNGw9cTqxiw6HWqRnPY1oxKHlL50kTqEkdPU6DQbGthLckB
iB1qAmTI2hS05iNMGAPjSSB7BiACK5qZfO/MOdqPHXa0t8KosF7p4ZKfEAJEI03d
7IlOlChg+2gc+VJTeOxzN9ATw6YbWbc6OpMTRVh1NDTzCd7/ukEMfMuG3cnM5RDU
lZ2qI7uWFPglF7KhnNxPVUHPFjQIE7YKP210t6dKfQKCAQEAjMZtB8pwXyMbd4jv
7RKUi89iLB2el4elkx97sEoz8/I5hqdhONTOqMLZq8R6eY2Gt/vEv/0EKtuRBcTz
xMt3Hy/p8WxrlsPKc6cK7RMX8w9ho9KOHZxAYBtkVrf6vK3rwcsB+OFcYiMz8nFP
X+L2NozJIdpEzJf5mqrFGhII70KT5JIgO9REBc7+RhwezTOfgr9bHYujbAHQiYL4
Ch18d4uJcly2/grIajtL4bzIzLDbYxpUuOsRSyhfQlW54PsvfUmexOUDulbH0USx
uWte3Hu4HWyL4LKtyHf8TgMPYiJkCwzlMlk5qok16ISXtX5iYwT2q2hvQ55yVxCS
5imYSQKCAQBGbIbElbttGLtI4yYKNetDUV2B/erMBzsdGwRZUbSaqG4N/YnihY/H
JK5pk9sNTbxQ51wHoPmOFX4Xd7MoNAVTh+KyZ5Y/wF8B2RvsjBwS6MenHb8KD/bF
4jMIp2hyXTrieZZFs0D5pa4ZPEMLVs905B06vZLbz7QWbvEaKLtVYkYV9hvMPlpU
nhLih3Rod3LfjGbt/d4yKn1O1DsEaXbGgwGm5wnDN48qZOX4kH8+IEGb27UFw/VW
Mhpb8/V2bpPirw5UAqDPv/m27TpB0lDwBYarLfgf7tQiBenpAzLjsH1qGdX6FEjs
w+IcrAAATtzjykHuavXUKOz+Q5OjTGGRAoIBADuj4rg27Urbvc5x2bzuaNpbbIes
LMeXX6UOkwqcwB0WbXH1Wx1uNLzOHGb7mjEnPa2Fk5uBh0YLtOoXBvXytA1+/Jh/
gHuNPlUvs/wwvaPXwuf1k+U35xvbcVN3q/CtlAUT3m1X0ovAZjFA+qYVsS38O9+j
AJZ8iZVsnW0NbRwe2yt3h16weNYqeJs2vAv5OGpbgqiA2lvba0Ov92p1TM2XzdL8
MXJl5b4rKSWdmO0C7/wM57b67k75N5imZtR5g0P31nyre+0E/Es6Q4AQYAKrssua
5MyQwO739fqLTiYb9jlTSUFdNmDNrgPmuff/dbSQzEGn1Vh8jCp6NYdP8ic=
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
  name              = "acctest-kce-230526084606888856"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
