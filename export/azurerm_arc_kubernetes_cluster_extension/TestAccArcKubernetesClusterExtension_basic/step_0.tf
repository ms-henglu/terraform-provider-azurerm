

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025030219474"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025030219474"
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
  name                = "acctestpip-230728025030219474"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025030219474"
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
  name                            = "acctestVM-230728025030219474"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1021!"
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
  name                         = "acctest-akcc-230728025030219474"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAp6Q2bKqqetNFPoxHqn35ROaPOMnWeBOyldlzImh/d83+QS0MvqPLycujGeENA04SpkdCx8bQxItJXCdsDniOS7O86/JRdHBqZBiK3/0RfInTu9TTOd3uhPglfiubxm2rQvKatF99uoX1sd09MEpR4FfspfJSg7yX/LQs88n6sLaIuz0Jz6mH90LTQnEzR5f1LSQKEpPu6bWu+xg78PT7XHCZcCNTaW7gTkfiw9Uw15FlLf8dF1Z9/qEAB/lLF7kAOh/IyrZ8bdtu3L0L/yifNa+5B1jHHQFXweRNLMoZ7/i1E7PJtJZyYX/qr6hx8eoJe9MEgrEGPYlKfVRS0vBiW8IIu6+VX54RVmJnvTyDPE1o1SFDj5RYLL6n4dS2/iP6BiQAL2/0PWf4899DBQKy5Dsi9Fn7uvFsi4FiiRkl5iets6AU0BAxyh3eR0E/Ct62mB94ulaKxXhjkNek9tudAEM0F/b/mWfMqrCVan4XYS9kFiaLYRFTKeMVvJUY4BSKyAVUrRLDCGgiTwWdHowJpP9BH3Ap7n2AaEI4zAjmFrwjkE5MtAWiLFbTDwAovRHOugEDiUYVE9YD8tSRackiH3rIiNLcINe6XPcIMB8tYvx45Gy1CKELnw4WOFUWFsspu0KfYxeyR9lpv3wLBtcjlIGb/KMDevuzxHdqQcMCMDcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1021!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025030219474"
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
MIIJKgIBAAKCAgEAp6Q2bKqqetNFPoxHqn35ROaPOMnWeBOyldlzImh/d83+QS0M
vqPLycujGeENA04SpkdCx8bQxItJXCdsDniOS7O86/JRdHBqZBiK3/0RfInTu9TT
Od3uhPglfiubxm2rQvKatF99uoX1sd09MEpR4FfspfJSg7yX/LQs88n6sLaIuz0J
z6mH90LTQnEzR5f1LSQKEpPu6bWu+xg78PT7XHCZcCNTaW7gTkfiw9Uw15FlLf8d
F1Z9/qEAB/lLF7kAOh/IyrZ8bdtu3L0L/yifNa+5B1jHHQFXweRNLMoZ7/i1E7PJ
tJZyYX/qr6hx8eoJe9MEgrEGPYlKfVRS0vBiW8IIu6+VX54RVmJnvTyDPE1o1SFD
j5RYLL6n4dS2/iP6BiQAL2/0PWf4899DBQKy5Dsi9Fn7uvFsi4FiiRkl5iets6AU
0BAxyh3eR0E/Ct62mB94ulaKxXhjkNek9tudAEM0F/b/mWfMqrCVan4XYS9kFiaL
YRFTKeMVvJUY4BSKyAVUrRLDCGgiTwWdHowJpP9BH3Ap7n2AaEI4zAjmFrwjkE5M
tAWiLFbTDwAovRHOugEDiUYVE9YD8tSRackiH3rIiNLcINe6XPcIMB8tYvx45Gy1
CKELnw4WOFUWFsspu0KfYxeyR9lpv3wLBtcjlIGb/KMDevuzxHdqQcMCMDcCAwEA
AQKCAgAzJtMIc0bTdXWScUFIz2lo0aTv4f5T40bBnHkaDaKfTrZ+8p0J6na7Gyyo
L9hFouPj4qiIxqxa3FlFCi5ZeAWLKcvCfszF56s+4ZI2aESWqIN3s6fD52jpH8Jo
7it472urYNU9pkl5yXg/jk8mVfcHqixmMjtlQP1rORriREX+96Ne5nAA8iyvkK9f
faT0+nPwEygTpRnoK+y5ZxqbGlU8ToszAURpTlCY8ixKLtnZXN7vmwEoZtbJBB07
UaDNG0Dre1lMKURsTOFV70Ui1SVHP1gI2tjei9NYMS4vNXeWll/CJECunp1GDL7y
XEZwV0YPh0LAEf3idurItRsUjA6mjG/OUIFAHELuINdJ74F43pQotevt9zeawp4u
Mungk7NguE2HaTJRa2OC3FaB96pdrrhSFaNW8w+LSH7d2GPik2Ig3eYtt0ZTYkbZ
o4SbrlUoPHoNP2y1nDOXrKbkedvPB28Wo4y545Tg2AHhI+90Tabe3Brz5v4Vus1B
OMRZ2Kt9zFtqzMIITxNzaDlVSqt9IDfjRhC7l9NCGGgKgtZQEoV1bmjuIU0VdVnY
2QE4KEgvLhaXc/FmhVhEAAjsEOGMeRci8VCvcr3Q2BuB4KbRUb9v2gY9zp0gxzAP
mkXE4WoVgy481uUceTsZcmBIHOBEiMkBAZ2WCnSiU9k4/F4+AQKCAQEAzYMYQklx
mzQqEdSA19ih3JLkMZL9MD6TzFJ12IFp5oOpyvpxPVSzw8iXo3+vd5N7TkFPPilx
zBCyuaOmJ462oihuHdv94qOSsPfb8y1erinv59Ju7w2rvbYIorErGz9snmaQhOaZ
DGccgXgR/2CsSx8rsG3fVHANsuyXGPpqthiXivEL2u70DEuPNrk1cTAE3q7cZfW3
zlFfluX6rQV7DW8C498mlBuTY9kw89XkO6OookoVU+yx6pIk4hAj9D7C122TA9b2
ZjMwg2LCKABnEuQ6YPr7kiVp0Ace8zAUa29L4NyLacL1jLcSD9trMlKa9kk1DL3+
VJWUjLQdvZtpNwKCAQEA0NNjO/AeiWYY8shuRarxsrA8XTpCCA9Hhge6s/eStZIP
BzpPsfEXP0WyqUDNRxA8Mb4vps5zT3H20CRMh9mkDdOQmrlojmoReQiGSWSm8Q3S
OaSbtGCneSRpiwm5VSialEy3GVzlrIM81E0lau1XlwUrJllROCGjZAI6cPlWfYzm
pr69MCL6FnsrwhQxW9+1gpu3WI03iO75XMgv1rA+XxIO6Km9f7hprcph7DCgGtie
GRkDJ3eBVsDDJsNui1IHqeBhoirBWNewslHlr+K+/l/I3e7ftzT5IiPajyK9V/iD
NWsfnJoHxnZltoRz7iQN0mFC4x0gentWM4JLiHbxAQKCAQEAqNq4mOYtQL9IfaPj
RPXKcCgE9DJ4cyZHW465Iu2Z7Htri8ngNuscVJXA+eZUbmQv4OlKSaHVzTw/DMZI
I6JfrraXW1NAs/F/+oV8I764V1M/uXKuER5jaJljWQFGkLm47iEJRxkM0SL7Sek0
qGZuyb5PsENmRsNWjhdUQoKmIP3trYxGGFlTDbMbdXQRU/GHXsu/bMrKfetgJeTJ
5VVmeHAoqL/Vu8U4gcaXMREh2FqsmMNT6MPGnxv6z/9A+1KB1m1CaNo7U1dl2d3P
9vv1tJDu4nX1M2woF3NyW4+6h1dHufabWYeFJ1vXrE21MwCqMAeQXerRSAAqsLzg
3sQNWwKCAQEAi9wYCUu/1/wmV2x/1m8wI6I/O51KHkXFfHHuzJvSiYMCR6/5Mk8r
Z7gReaQqGB86gYJEPe7lcd79E9hL3WyZoJ0Cq23kJgXKIArijYM5ABdmpi6mDf/y
CoOloHZpxyxDo3Fh7D24oXrgIbxthBjj4gSXKr8FU5fL665GX+XO1JWq4SC8auHy
J15lJz4I9OR2l7wc5tTlzfNn1YlJ6PrvOxNIIvGUNldXiAsU3HCQuoo8EMkcwLEc
UfMWgP7BKdRNx6u9GDSUfCExeay6LbuqeYnDaUiUUwrKlN/4gIce0y1hC0TsziCn
dndTlhNN5cAF9dIoTx3x47Z5PFRWrFYlAQKCAQEArp57P+Te5kMPG/yGNTLW7Kvw
WQ3+YSRRWyjRyQya82s+6wLbH+8x/CqvVAQfUpSg11VNuSzn3Tmwod6okEtRTdTi
OLRaRRmOwZyuToHT+hsXid1cQ4M9B0A8JGBT/sF9X8z33obV8AWACQpmtYmg+TWG
BAi1zvlsRe1L7+Oz7QRG0n1F/eny2P1x+vcrx8sHIRTTLXJw9CaCe9EehrY9rktL
EWc85ifYSxQPXl/olzk+YAplR+jYMO/wFocy0JJWJ+MOWgsd2teXOx9PXcBv07/1
NCFIB5qSr4kSGLXwfssZso7ZI5OCbCF81rxyTDTmrBrtk5Aze4tGoughJbWMAQ==
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
  name           = "acctest-kce-230728025030219474"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
