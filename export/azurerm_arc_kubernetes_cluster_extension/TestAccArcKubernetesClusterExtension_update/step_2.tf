
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005948259962"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005948259962"
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
  name                = "acctestpip-230707005948259962"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005948259962"
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
  name                            = "acctestVM-230707005948259962"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8825!"
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
  name                         = "acctest-akcc-230707005948259962"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuATGZwVgUqOtLzafreC+mSVl5IzD4vMsOrv/GWT8bHFhyA0uQMcxLrg3kDnePXyhyP6K+ai8xiYp0Lsp+NZczphpzJoaZ+yRpuOgAubGa8bvCnFf6sjEL2iqmIBJBKKdZuAE9ajLu+LLk2+VWLkV2nLVFTWJw626timTS75szr9QIfomkWB5RUJvoPkEO9+OZvLvD05I7X8wyUfteZAKgqEe51dGeFDgibg0JRd5m285iNy3ZE+vU/3/3JZps0BIeXgRMBJKzolgo4CnbvweSSfswy55G44jRhaOM6ovQcLX3cFEKiiCmmk6FaOAzhKBTRQXCHzJpZaPfeYi0LqaXpv7HrkclZNAMGKNv0XqaXjlep2ZP1J/EahPfVhnyHxMAkph3N0rfJe9cBqGIvL2cN9VOVGA7j6dILKyJXOjxRbY572AhucynWvYCLNb6hGcyaFLJu/5OZ6z5aCVM8jlM5oG6zMSos0WzcKXcq2fAwVP7/tLSaz6YNjUVCe3ThDfCKVOjJ5appOGWLU7WGmtUufsCZjlpL3aPNgtMa7lk6WEV0znT4e7au0QJnJPMu2SeWgpVRVVVH1z+2lPqE58vQpcQdzU6kFFZIus8VOETJoAiWPly+xtoQdR3GQenYqjBQCdZ6TFYIv7wP9+e3vkH66EaOOpqCDuDzpvb4zONA0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8825!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005948259962"
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
MIIJKQIBAAKCAgEAuATGZwVgUqOtLzafreC+mSVl5IzD4vMsOrv/GWT8bHFhyA0u
QMcxLrg3kDnePXyhyP6K+ai8xiYp0Lsp+NZczphpzJoaZ+yRpuOgAubGa8bvCnFf
6sjEL2iqmIBJBKKdZuAE9ajLu+LLk2+VWLkV2nLVFTWJw626timTS75szr9QIfom
kWB5RUJvoPkEO9+OZvLvD05I7X8wyUfteZAKgqEe51dGeFDgibg0JRd5m285iNy3
ZE+vU/3/3JZps0BIeXgRMBJKzolgo4CnbvweSSfswy55G44jRhaOM6ovQcLX3cFE
KiiCmmk6FaOAzhKBTRQXCHzJpZaPfeYi0LqaXpv7HrkclZNAMGKNv0XqaXjlep2Z
P1J/EahPfVhnyHxMAkph3N0rfJe9cBqGIvL2cN9VOVGA7j6dILKyJXOjxRbY572A
hucynWvYCLNb6hGcyaFLJu/5OZ6z5aCVM8jlM5oG6zMSos0WzcKXcq2fAwVP7/tL
Saz6YNjUVCe3ThDfCKVOjJ5appOGWLU7WGmtUufsCZjlpL3aPNgtMa7lk6WEV0zn
T4e7au0QJnJPMu2SeWgpVRVVVH1z+2lPqE58vQpcQdzU6kFFZIus8VOETJoAiWPl
y+xtoQdR3GQenYqjBQCdZ6TFYIv7wP9+e3vkH66EaOOpqCDuDzpvb4zONA0CAwEA
AQKCAgB2MPLxhl14lpIMagwjVN92Y7PPGK5UHRXCX68YM2mBiU1hfT3A829eb4mY
g+J/IYaUHxFKCxu8NRTUcPIjViNjujbx5+Sf7S0bwMWsN2coICy2S11s4ihHvvUb
YAIGDSAFzErDMfgxJBjXCGsnAjHMDcdYiPuECBiNGaT2mEcwf2ZLfGy7IPijCGnE
PUx/3DWNX+k1rnVevTurfBxF4MMvZacAtWiYrHGbYwly7WH4+HY+tmy/7AJTcyec
GauoKtih1AFOG+GaSFgei+p+eUZGfHMwZa/5h9CWGrSY8GzL0wZs8s4COeSwondh
IJQBR5du10F3/RZS2aIuHdssrz2n/9xmMpWslEiyFgQTRFTHdX8aD9joB//UncQY
X/Ac1wkOk+io/pWVVG3ZeMSr5YvLAbQNEXrBexS21L1xeEIMYMT2Zqw9rHke+9HC
Ml/W7xPI2ywMmvLDg97SRZCn3OjbzY/xTRwSRMmXlAgV7715kxRdCfxvH8OuKbNV
/g2wia07lmOVax6acHkb9iWl/sUgy1lsdR4B8b/CuxjGAMSMWBazvXmMFdeVmgfV
xZzDiA+raKcd9qJehs9j+mUTr/6VFZPj3aoGCHrGwsepqKhDxJaL5lvbK/8qNrlt
opuWQNSSuAAQEUpHuxd4yl59CyVzAh3ydooU39tmyFKIyR267QKCAQEAwUPnl+IP
GC0m4k6GuX0B+cFSE3kAXoFE8fzn1wbzYmV2QVg4bRNlxeEJP/MxEuYdfsNFwNpv
FDBhz18h6x+YytYcv5PJuc0KQZoP2TaYIbaKloW9UDhbrrE7OG6iDEH/bkLQQXkX
DUNSFihrwauJkopB3koTCKv+JyxclAZPcC86RNZHMg6Zwcs6NfIhOWcp3tyP0ivn
tLSQQIpkLgYQjYkK4jevHBF9JYQe028V2F8t9o2gM/cxXeTSvXIPa0ZA7sRxDvUZ
LY4UQ9HG1bJLyG0cAK6A9n7wvGbhC1BIGeCOwh0TqmB19WO/8mYWYZxtKDMBdWwT
ZmTo7BLvV4hYPwKCAQEA88B9XLil6V8ngQx8K1ZyZks2S/0bLkFv97cuhcW8h6iv
gq8OEIimrYusRgHzi+G8aAnGn6SclAJdJSO4ffrB88GZ9PAmE9SL0Y8rchF2EcU/
OYvvZII0IXDlmr1BNfVYj8zxYW9qSD23nife2ZZzqUPmhpNI5elUzQbyr0+GSqGO
EgtZC20uH2ExAKKvA+HpOPiodnYp2i3vt7uDKzCTSRqT/fXhPmlNHRQP29Ld25e1
PYVPSr0MYFlMzGJvTMpt8s2AuN5XNqgxXqdzNAS8GHT/SjJy0L8Su52EIC7v/Ocm
XmbIwIYnMmnhc4RG5x4BgVTJvU/7XXC9Vh6nlWeAswKCAQEAj0fTi/PJcwgOetry
4NN/wnUDb3JWxrmZrrnr+6uohvtnx5wrARrPafujSuj2Kee2WENXFFoc3d/cs8v4
roMXWNGSMKnVdU1A3E/mjgf+k4fsiRmPt8iAmCvHFthWhTXstAcOtGucnnWZhtni
wYt2C9E6ch2CrPwuCUbHP+rJvAcXcO9XixHuBhGwD0x6Oz9zeEkWyx9Hwd3X0DGJ
geF3JidCjWHxDaMdn9GqtN/3VxmBTvfCnKQX0l+RqWfFbKeB/kJe+1LUnsRl273L
ZqSvsGDL0OmOrLCBs3umPif/vEeSLvE1oiuvaATSylfLIgTBnHrsCuzcGR6Y3GRR
Uxi/KwKCAQA3iGxHOp46C/7BDOohKYHIwmvtZg3SPQBYbHiB66nnMkxCNsW6iJeI
xGCMVpd5EAXPoiKJboRpyBwWgQvgT8fuU/ZScoAKVotARCD+zPGcXNbpsnLo8C0W
TVVSKrn3pBz4LhX0P+Dz8nOp6aWA5yEUuC6GDHo4Py+dwm55+GE9EY9/luxDiS1P
4uG6JlY/STHMVAJ1crhYR8zsjCD3LwrvRcnfuywE/xKdhFuUlncLN4YILR4Chg2S
yeWQTwDSevAPuDgSZj1ya2FMElRRzp5X6BfdfJ7h5hZLfjiC6I6ujK8WJM6p5iZ5
+tttaP6KWzC2mW2Y3ucCw9OvEi7WAA23AoIBAQCx0IS45KFjU8Aes5Hu4VlI2NIF
4ktH7HiUcWBH5zOxJMVZZeUIz+4mdOdGVmWtvciAAkXbpI/diIf6MCkgasXxfFFZ
UTlHFmgQ445qH7ROAZtXba6IcuxL5w6c1RYo5PZ73PvUuUKbueOb3hNQMVfR6Jlk
yYKpnOOOZdzx79o4vvypxm4IY6vvu654Lz9GAl7tGxW3/Scq+DbTjPs1p9xbUfW0
sn41Tvg/xf1oZnVr4EEQS4PFU2lRAzqwdOed2+iyRBMB/RHOvSdGhZkPV+9HFUw5
nkaWAlQr+p8WwFczANpSqr2C7BQzuSFtiXSxyWdx6BdFohxf+ypTc8//oQhD
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
  name              = "acctest-kce-230707005948259962"
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
