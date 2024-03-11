
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031322341111"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031322341111"
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
  name                = "acctestpip-240311031322341111"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031322341111"
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
  name                            = "acctestVM-240311031322341111"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1372!"
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
  name                         = "acctest-akcc-240311031322341111"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1/nt0kDdWuTLfJ89gxwPaw0wNNFK2Vrmw4nOjnE+eknW40uvxZMhQ21/YGSK6Ckb/IpfR+zyWmu7gAGjT8ZtfNv5m4lGTIcVd0t3gMd0qFH+G30upKPG0O9LBiMZPLF6MV+SRCRRlKj21AzWMo3t8UQEfQikZr6ryKHYpcJvpqOzJdkVKDhXER/aR+IQQJpUM3wycZGUM3yeRv8VoV9R29rvqKxYoH7v9SxltO8Wd9wzAIngWjC3qi+XYnC+osZa3zW438iEzzmun5rv559+OjV6VNf5pgJB6nlIM5Qv+SdCYkEFPleFiI+kFhUK52lFibTD1BCHCiXPvHuPYyHSowgH4Nrp2tsQhlCT7ll8RiJI/hsjHF5BssLQ2PES+Tz73r7q5x87M8q3ei0QPSUVUJdWrWxT7eVMFSyYUlXsH5gkU6byJZPbvEWNJbi3IS68tKYwfNiSsyTYXX6jp1E6yp209cgxcCWCUsMtoY0sk+1gXxloulJcWqb/FHLJsTfuhaMdHEQvSS8OURF+UkaZE9Zd1OUoZiROJSJQYIAy60Ux10nCdXnLjMWVCliyHrnrzBFJQp6NuuOqaGiSNhbh91Jcpm/SjbTioFbkpwi5VrA5e2hOd2I8hOi2m3QqLbOxJWYRapeJRjGiiB+ikLd0BldvQOXZdANrtMdbl0dw2fcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1372!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031322341111"
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
MIIJKAIBAAKCAgEA1/nt0kDdWuTLfJ89gxwPaw0wNNFK2Vrmw4nOjnE+eknW40uv
xZMhQ21/YGSK6Ckb/IpfR+zyWmu7gAGjT8ZtfNv5m4lGTIcVd0t3gMd0qFH+G30u
pKPG0O9LBiMZPLF6MV+SRCRRlKj21AzWMo3t8UQEfQikZr6ryKHYpcJvpqOzJdkV
KDhXER/aR+IQQJpUM3wycZGUM3yeRv8VoV9R29rvqKxYoH7v9SxltO8Wd9wzAIng
WjC3qi+XYnC+osZa3zW438iEzzmun5rv559+OjV6VNf5pgJB6nlIM5Qv+SdCYkEF
PleFiI+kFhUK52lFibTD1BCHCiXPvHuPYyHSowgH4Nrp2tsQhlCT7ll8RiJI/hsj
HF5BssLQ2PES+Tz73r7q5x87M8q3ei0QPSUVUJdWrWxT7eVMFSyYUlXsH5gkU6by
JZPbvEWNJbi3IS68tKYwfNiSsyTYXX6jp1E6yp209cgxcCWCUsMtoY0sk+1gXxlo
ulJcWqb/FHLJsTfuhaMdHEQvSS8OURF+UkaZE9Zd1OUoZiROJSJQYIAy60Ux10nC
dXnLjMWVCliyHrnrzBFJQp6NuuOqaGiSNhbh91Jcpm/SjbTioFbkpwi5VrA5e2hO
d2I8hOi2m3QqLbOxJWYRapeJRjGiiB+ikLd0BldvQOXZdANrtMdbl0dw2fcCAwEA
AQKCAgEAj17A6e7XQoxZLHxFCDDrZ0QU+SrqRgla4PktHk+8is9TkAVhRIXb8ffR
M7rqnx0TD/0HLSb05uNXT61GrSFq8xTPyNlCynBt5og5Z0qAfXAYgEUEXpS92VrQ
cd2A1lJ2bComXYfChC351GBFHMAs8RkW5a2D/RSb0o7l03uURIms1fYaXl2wJpT/
gPJnmYsZVCghEFT0jY0vQK/6uuoc3BalO1JVbw1020tCpO6F+sE5NiVQwm5OrfHz
y4xOcJ2+Gyh9dkiVKT8AVcEzeo3c7GUttP6+Id6jxTQHov2/LuVJ4xGImo7c/P9l
jKchWub+G2DdEnx6OFlLYrKfR85fFVPSXXsniGgNY6ziM5iEhdEgTYSnSRKK1SUJ
2eU5VOe/WXtXwu6UFWNFEj53rRL7aWh++k62AeEc3hr4hIl8ZR0QzdRCpwNersXB
jYI+egadZvxL6SWVZem1eq5EVn7k3MPmP8q1LEQA+/Ugy5j2nPUaIbfKa9XuUf3x
ADl0kKOXBYA3GV7hnUlf6ayEPqnTxFWdlVUG6+yq66WO0QssgPWN6sCg7Jj6cDL9
CeN8Mx3c6YqvhVhRN0ag9shlN1I3nB18EDSYbUYMi0mqH3Sej3oqItGSoEVHnu4i
IWJD+bs0Kym2tLwJrYXTHgTv0ZdUcQTd635febmwgyz620ZkWxkCggEBANwDt+D7
qfjfGrCRN5EJbQrsZNajJTxwsXsY8Ven4r/5Pv8M73C0GhpEGd1jzey8JPTCqGHG
iCoILEwRKIlh1ebjYCXLmKhu2xlIhW/ErVG388+rdCJamQLCkKUIY44dL1fGTvjn
1b5rGr+vJr1B+5n9NKGKHq2qOLq6wWbnT7o7MmiWVEU8MqBNrqZEMOo97wWHdCup
vOC6QBjZUpAqXGv5zmabZ3/Q+jg611KYdQoM84A8F2jpc6XZdcMIaQncs22+qxTa
2o+Ej/y38OfyG0aXAw/q0Sh4yQ2Llhf2Tv8KH4rzPAYpwbfu+zVfdxNI7DOifmfh
ib9B0vz3qORYOC0CggEBAPtNH+ZGye1PUg/KgOnD6kgW7gJBMUDN29OqqMn5kk0W
GxmFIqE9n03HV+MzjGWaLEPm8YxQFyaZDi3Z2P0fPdaqxsnoevvhPIsCtSz6jEPt
kLYdb9gsuYLPcDg3KTdjj+NncS4CM8QrGjPlAUKK+u0Uu+m2v9eMOEs2H9mA40ms
O+DEvAPyC6vtErC42vQnIv7IfDB1MwsVKrMIVJRmDFsrl+RoZ7tEzAi/FPUbCsjo
ioG76UOkq0bgceNsoL0p/lnSOCYdwT39H2K3Y1ASKEc7H3CbVAh9SmgdxCou6lIE
3ubqtueTreF+AOVbAVsGe0cDKKGlRjbyJVuoawLM7TMCggEABngZhQUBV27/8uci
MiKL0UFoKaN8ac2KemseVYx7L1fd0VQJClBRYCpWdFsF6AsULxo2J0HWKR46ZzYt
8fQtfO98mT/mSjWQPasTOVkYG4oEIjwRWx082IbuB9w6SSh0huku00TF1SaDD9XP
lssE4d8/F+zewA58QolRPHxarMgm0EpzSeHePzZphzwEEC8oAwqbkNkZ06XGUrS5
J8IHG6mptvyky25SnSqlwCj5cAU3d7LMoWoT23GMc+KgbAjQQc7UavWQbZ3hOfYS
oE9PHAE+ts4Zvk3m434SOLwmUHt0t/o07p11s7nUKxqWfrurLk192AIascP2tzd1
ANnTNQKCAQBW5bZwJG5S1yjjOP0W2J48y2EF+pETfZvUN6EiJmDGsywvyO/OncZm
WNY1RG/5+jPwTv2brV40BJz4keoMrS7u+iK/UtqkGqCa2RbZNNIn8xAlSUyRjfWg
HCcL6VchRhZNZkmmxTAtV1I6O6gR4IkgThkkmgMAgAY/S7n7tiviH+KcuKrjGmGa
0+GwpltgLeBWBfGbuAsse+dF/U1x+0+ufwaI/ulPwlxjcd/HWdCC5JZwghAJSfnI
CniXUcrLXqgLWzv7QjK+QrcFpbB70auH5hPbFnsabGi8U/6vL4XrUq/ZXbRdo51u
6elZZfy0AyvBxH/aVZJQEa+FYFmQoFgtAoIBAG2yOLdgzkrDwEKJnVmg9gCSf9wN
VFt3p7Jvf5lcNEJl7K6G2krU7XFzJVRx6NMN0YYjqGCmA44HS0TwHYF2EZ68xORU
3L0XkJOE4FFF3SPJPsvXi51/TJMEZPo/46aE8xsiFqaGE48D2m7y0MsuaMziVjJB
wIQtgKcIir6PKlCDBRSfRaoDseg4lne/j1sXBpFogC5dFJKsT3CFLQ+SPdoW/z4c
WwLn/loYA+l+CkSStK1U3ILnVEanE/1BOKm3uui7lVEd/On+8+N25mlj4cwjtWWG
WMsWkv03Rpv3WATMt+mTMUaiao6IzrCqVj0nlKye33OoiAqPkpdyuC2R7zQ=
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
  name              = "acctest-kce-240311031322341111"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
