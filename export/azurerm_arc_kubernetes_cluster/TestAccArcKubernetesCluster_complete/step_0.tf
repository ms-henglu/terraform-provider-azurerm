
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074255865747"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074255865747"
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
  name                = "acctestpip-230616074255865747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074255865747"
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
  name                            = "acctestVM-230616074255865747"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6926!"
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
  name                         = "acctest-akcc-230616074255865747"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5IZlAtbsOEoeq3rujEcosnEpmHYya9fC71bbjLmikWl4NTsf/R4PkJlqwzQ33tSn3skvC1bULD0naqlQvtXqR+wiJNWMW41RsJMzTavaorVr8qhnqdqupGfwemKN9RzLyvqo6Jpkow8ifre7OGxBPhIewUuKKuhFtFoI51xjF50NTAhLcOqcBgDYC8gZ4UuYNXdi3EXDumzkNP1xkiYI5BUbwCDS5a52mEuBLUzc2lK4ijbxOzHlaELXB6J1nyEbd6N5hV86ntp4E5sZdy07lyKNWowDwYk40ivcbPD1yrn2bUfQeh5CRv3xOgBcQ2MSPdX1MhxCsLv6VRKDYT6/84axMlZGYvW64ahPNRZbqaQwDB2WrejrMjBKNRpP/IvIm48c/lseuB3tb8cfjQyDi4DwJgEySajDfIUvJtQb3egPmClmbVv+16xpfpIfxGCSHvGYOHkIPhatxzaVNZKrS4eUkBI8WqCRVSGjigwLQbFWiUJTrRqWYjHkNi0xpPQz/aFJujuJPWfFgLqSI2K2eEio5CmCZ1lLjOeaCSA9mfyZU483kqq5jlGBpKEzd/pjT8kYZsWXk74NUm0uLOp52hpDkN/RIhdNdrMmc7uEQLRtW372K1MjoK4e9S9BdvmrkDwt3ugFITDJ/765zV3SOHAF+zHc8MCXxfoRqnk9FR8CAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6926!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074255865747"
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
MIIJKQIBAAKCAgEA5IZlAtbsOEoeq3rujEcosnEpmHYya9fC71bbjLmikWl4NTsf
/R4PkJlqwzQ33tSn3skvC1bULD0naqlQvtXqR+wiJNWMW41RsJMzTavaorVr8qhn
qdqupGfwemKN9RzLyvqo6Jpkow8ifre7OGxBPhIewUuKKuhFtFoI51xjF50NTAhL
cOqcBgDYC8gZ4UuYNXdi3EXDumzkNP1xkiYI5BUbwCDS5a52mEuBLUzc2lK4ijbx
OzHlaELXB6J1nyEbd6N5hV86ntp4E5sZdy07lyKNWowDwYk40ivcbPD1yrn2bUfQ
eh5CRv3xOgBcQ2MSPdX1MhxCsLv6VRKDYT6/84axMlZGYvW64ahPNRZbqaQwDB2W
rejrMjBKNRpP/IvIm48c/lseuB3tb8cfjQyDi4DwJgEySajDfIUvJtQb3egPmClm
bVv+16xpfpIfxGCSHvGYOHkIPhatxzaVNZKrS4eUkBI8WqCRVSGjigwLQbFWiUJT
rRqWYjHkNi0xpPQz/aFJujuJPWfFgLqSI2K2eEio5CmCZ1lLjOeaCSA9mfyZU483
kqq5jlGBpKEzd/pjT8kYZsWXk74NUm0uLOp52hpDkN/RIhdNdrMmc7uEQLRtW372
K1MjoK4e9S9BdvmrkDwt3ugFITDJ/765zV3SOHAF+zHc8MCXxfoRqnk9FR8CAwEA
AQKCAgEAz/V5QI9C4aqZpGU3ZhJvd4tBVgvhsH/lVhZNrw9TYE6BZLeMUbQkZ+sk
28TOPwp4RWYBWKlIZYW1M/wmjbNvAspg+/IVS08cErqxyjHkwYKlXGpiA5EMsnIf
xc+f7Xmp/uoCAcJWaIiiVHxwdFUXPhwRPse2UXuTyx7P0XMifd+etR0rQfNNzqy/
7mDHJF29gpJFNbyK9ECZn5sv2dag6qZG3Z1BLmCIbejwAcBbjpYOd0CuX7b1U97X
fYway5e+Pi5WrMdPOjYHZZgUIX7ZJpz703VtCZcNTT061yykEDsQhLwAfNDCcYYw
Gh8v1ub2N61X96T+D4TQttAlHL6Uv5j+WlxoXPEOlX8c0hkInCWbYCx8O0Xnuqbt
KWuZQU9aad7RQ0F14hMk39VWpFCC2gBIi+eTsDxS+JhGJphiH7Oh/UpTYpsyfrYU
ze2bbb4oibVm91zB/aBfKlyeENK2js39WTH4dixR3FfJMC/wSGoXO3ROrq8gvAFC
cmzk3UXlgpvQUHTGqIXBwHjMvuW21mMxHPfj16EuYQ2IOCLGQMZE7OjMpZbFvilk
nLzk3uLKOoRbKRKHcchlOG/3M5/NnhcL3cCJ9X9gErR6dMHS+Tpf/sezWlmOGp8y
+WLZYipXm5Y5mWlpcjFgD+8kpctyOgIFfqRR2rm2e/pYtv71tJECggEBAPY5wC8h
2lkSdv4U4SW2XUa6poGz+dHlekuWT/sa+doruGu+l8AzAlxb0hdzaWhxHw2KVmO6
JKCU7xrTJJfbM9875qoEC6qVkWJNg5mF1D68W21QaZLPS6fGPQw0pGYbNLHkHWcF
I7ji12U82Z85eaOjAiS1eTLMUme2NkxC6og98IoD3nOp+nwgi0dHK5NejXMTdW5+
kLr+GDoD1ZyuA3Cc+s7S1jYLHojCX7flE3y0ZtsnjajYnwQgkY2wtuGY1cdqMNKa
j1WFKm9JzDC5x+C36Ndb32ysPWKR+qIqGdRR4VgMrFduvSM0EeDRKj467I3NlcFy
aEVAPEY2H+s8vqkCggEBAO2Yw0GchSv+rjaCa157t1VEKbdj3rNvvZLlrYfl6Kpy
EHuqLh8WBM+UaRSvhNbnKEtCspWevlnmxPasa6pQNhP/UGIENpOjWAPX4CiONrYL
hgOeY4hItReJM0/pyaFArQSjz149aG2uIuZT8sCL++e9b9OcSun8Ojvk/E5Kh/KD
uhyAYH3Ksd3k80anfnamFmT3z77CRK6dLvxMCFyLdNKf0SK8hkl53Mu1vltP7iGW
WejfbWS8xidFkwupUKAmUdSQbNZTiNk0P92yE4KRUTSt9gpnB/EggLS7PITYrANX
hSJtA1oDaLLEroI9c+1ST0/zkUvb8Muoaxs9Qz2YeocCggEAK6Nakz/dsdGa8zcC
HCvw5hsobW5XRUL1ZLYUIL3MMEV1Xusde/vOXE4NswhKUy9RQJYW73/LBAbBRbDM
GHnJ/LNiExm6c5YkeRahzzCvyBqb3YjV3SYOE4MHyMT/qfUCZtC2AU8g4KCbah7Z
tuV50G2QcK8U9tLNfAIIJ4XoiRLpMZyz7S3f7eXaqVxMtcaZLR7yvg2CWxGze3y4
fBc/FtNLhCJLwrI/zB8e1bmstXpHjGm7KoSR0ipvgXwjPWJX6QrB8mFgK9j5B1Y9
8RjL+uC9TIXE2D7CdljG4byybTXByVgdpzVCIh4VWRHY+cR5rjwUYX+ESVm0FQF8
sLVIWQKCAQA8rKYwOyhG8+LJSMTie/V1cNK2YmqcqAxhVwXZjny8CiTrb6oXhif0
WpH7Fld2CdHgZkf0rXUuwB/MXnugIpusv6ZnYWwOh8gSMy6rLKYMFyVCB1CjnO2h
9QeFgM5cv4dvh+WMy2G/oJiI+SckxJqvs1C7WU5IMoEsim1kEORmqfz9CkuZ1AlY
AP+fK2bAJenSHvaOYE3pyXoWM9Ruza4nm2hs1nf0i4o2+1KBPwgwy5RqQ6RL9Wkk
3j+O2s4cF60N+1PP58Uqso0csD0LOtDiAwqx3V3J1eMIREhQJITI1bDJ+czBT92M
yW1HFSplkH9wi2KvXJtBZuDzM9HYCPhBAoIBAQCzVC7f5mFa+D1zkMjhCFx8bWzp
ttupZRf+sumnCWA8wAPRE30A0jqMr5YGRnVgiXrcDfr+KGUdtLTE4A5p7p8gwiaB
JK5+hrq38Nz85XYizX8/gICOiBjV2hLcTpK/WfO5lQC2o5ZmC2Rb/KUTKiSMc973
dvMdPpLz96QlFNumqGaZshkTnDVep/EGiiyCoPnIAZxap8JBkECmnFPEcjCtc/L1
6ab2v5jDvEW2rvCuIFGkb5zAjL3cZ12hzMZGxSGlN3QK/+psJDrBEwVe0qyNrtvB
/B5+ACPnM3lwu0qwAARDA0l8pmFqMw7QYKwLVxt4tHfX5afeyO7xx2bgspS+
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
