

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031733456639"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031733456639"
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
  name                = "acctestpip-230728031733456639"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031733456639"
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
  name                            = "acctestVM-230728031733456639"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2457!"
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
  name                         = "acctest-akcc-230728031733456639"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsc+iOFAX2vp0QInQKosfT65AxlrQ0yDhO8WTi+Ojrm4+hsyDR49z89FSFrPcDqalJ+etq+PeTUgXQOKNoX0pmxr0xJ/WyCpTcUr8QYx9+ElFULn0K1Am2utL5PLPj7x+TFkWWCjxLlC2sy1Cfay3j0gj95XJVeqGLj/pzMAZqLdmso/xsy+YPbNgij9VN14qdvGP+j4F1g75yMShSqXLRozrtE/3JxFNY5rlExF1vPvz9UR0U9EgBvVMqZnkwzXXBFcPjsMExQLg89uPvJP+hwmhmdPvAlQsn+4yfQ+48n4p7mf+MLG3s9oRnQSXPNq8dZgOE5RbhV5HKqa1FdWizB0tOXn9ecHnm60gM9jpVy2M1QnpsMSA3p5lpFcQqFT5sVRfIwjMsB5rUUlPh4dy6HBSbV1IHuu8oFlvJ+hBL28U9QCIQeQfsAfJJ919j87jJZ1rp0FOLJ5lULMAgyAF3F94KWh8hw+KSGDOWBAsr3/K85xOG3UkGyHRB7sERa6qjs26h31KHTOsRD0wnbNkDT96dB7bmqBNbVZ6qAV98GfQ+I7BRzH4p1y+0u6lOzwbp+fOt6iqVkcRQSNwbQ0W6UUqqTSgeJXrnoJpy32aT0BYmpPLxJUTs0oKwfDrAuHVsj8bjbvz6wN2PcG6tyITDb8F4MuaXNG6r8CiRA8jcTMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2457!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031733456639"
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
MIIJKQIBAAKCAgEAsc+iOFAX2vp0QInQKosfT65AxlrQ0yDhO8WTi+Ojrm4+hsyD
R49z89FSFrPcDqalJ+etq+PeTUgXQOKNoX0pmxr0xJ/WyCpTcUr8QYx9+ElFULn0
K1Am2utL5PLPj7x+TFkWWCjxLlC2sy1Cfay3j0gj95XJVeqGLj/pzMAZqLdmso/x
sy+YPbNgij9VN14qdvGP+j4F1g75yMShSqXLRozrtE/3JxFNY5rlExF1vPvz9UR0
U9EgBvVMqZnkwzXXBFcPjsMExQLg89uPvJP+hwmhmdPvAlQsn+4yfQ+48n4p7mf+
MLG3s9oRnQSXPNq8dZgOE5RbhV5HKqa1FdWizB0tOXn9ecHnm60gM9jpVy2M1Qnp
sMSA3p5lpFcQqFT5sVRfIwjMsB5rUUlPh4dy6HBSbV1IHuu8oFlvJ+hBL28U9QCI
QeQfsAfJJ919j87jJZ1rp0FOLJ5lULMAgyAF3F94KWh8hw+KSGDOWBAsr3/K85xO
G3UkGyHRB7sERa6qjs26h31KHTOsRD0wnbNkDT96dB7bmqBNbVZ6qAV98GfQ+I7B
RzH4p1y+0u6lOzwbp+fOt6iqVkcRQSNwbQ0W6UUqqTSgeJXrnoJpy32aT0BYmpPL
xJUTs0oKwfDrAuHVsj8bjbvz6wN2PcG6tyITDb8F4MuaXNG6r8CiRA8jcTMCAwEA
AQKCAgAHgSnpkofPOC7b4nUktoZ1yHb3aDHUF1kqOqaFivAHlqOQ8OTBim5sZfM+
/gxVmfbyfja4QH/LZzWECYvMuwmcgEDAY7ae8Bphd7a51YIjjoQcahzCDzn0l2W2
ngDgoiX6dvAYfHHhcIqleU2LHFUK+RJ7ipjaxXEwVoY5nAn5MvRkqOqck2+revyi
GRYxpgnIx106RI/efvdP3+ymx+SSb7QrAgz+Wx6XC5yLd3supLuhKGh4eSUO5h98
MQCUtJsEleAUOGrlHb/8ytGANgbSEDf/1BAMWx0fCuCaoqU9ptGCPGVgDMAiGRwR
MnZnnRvDIs3FScerE1WRmUOfTkr2nGHwbO5mugt8V33F39XX2+6uvzMI2h0xyv9l
gLBBzNDO6z1S8X4OOKUISYp+P0Ne9LCHts5RMEpezyHvG6Hg0bnH2N8dLPscpJ7C
WO88c8AHOeepSUiU14q36Lrj79w6My9hnFBHNBeArAMzfnGRVGFsEwQyFzwRsdCa
Ixjym2mV+1F6iONVkc5KocyUWLRZTPETLcREvZGrR2XARvxUSbPKM3HEFrIqRdCu
NKxzYrrG7y7m1YKwvjWaDzCV7Io+b3iHiQ1tjtZT11unATPWYz4aSSgSGghJwFJx
sj87V2Fc8GkXq0nOoNCiWdLHvW6p8fjF2pScaF5s/aSHZPdxAQKCAQEA4oPXL7vF
tLCrOG5/lbTxOfzHAyK5h3ZlTBfWoyM89bNI5uz4Flu/QAexZZuEG+T+wyhHGTbo
83Yagv2y5D1wHTdADXjM1474fN0xAJRDMd815c9tBbr+SntO+q/NemctJMoN/b0o
hBYzorxULt2WSbeSNp3KY76+Qbf6bB92OYxDujgi1lDg6K4n9P0H+waqlhQaDp3M
UdqZ8BgzNpKUhk/ONmpEJpCPhudLDewObwuFlmNXmhxleYf5GAHT/Q9c+qpxIulz
6uVVHTEG1gZXb9HyLFUiOVZNDSFvzZMcSOuhRsLZt6NHwLtR9AksFM4rM9uQf/eP
biCcPzH+UaKl8wKCAQEAyPTU+XlzmAYJK2HMLWNxct1doepQ6HGV/rYoBrEHr71F
EW0nK1xrtqkjQsZbvNnJF6XDHHOv5c5JuX+At6kBEZRCfopcyqQwEhqFbAkxro5N
8RiB90iSdUYN/OpI68JndoH6fx6O0qdIzUK+UEYMoP8pdHjeK6qBiXD7Mhol3j1y
a3vtmIwqmjr4LZ6P3POBRQnJyfPm8L9hdjVSIB/PkYg1Vk6KUD38EkhxWtTvbA2S
3Y8ZTwPUNqTWUSgnrJzWW/8bmgxLiebBjrtrK3rU6jXPh6N/jJJKOwrSuNJ6cH8L
zuFNnl7mBqOs01O8RSIkkTUQ3UU7nvGBRDab3FaXwQKCAQEAkOwdHxMZ+PMXePFp
e5TayWjqwxzSatLbGIYf8xw2glSEjgqK53Mnt4W0f/ex3E70mFQKuR0iibHEYI6E
h/au5mJU/smM9VUpsmmqUl6JZz0SNMgzTnlG/MxLyaP06R1eCq2jqfX+GBREURgB
HEL1RpDGYV8vAAYnn9BfzhGLCGKvalNEJq50Vyolsl65XmfzeDXAPh3DfZNI7g3t
pjq9//jLTJFMrQfMbFlK8ctXqMBMZd2FTLpiShEu06dHxB6yNEYcQGPwoBa+EAEw
CHriMk62jJqjXN/USFRePb6jWBw5gRZlSVKUM8ElO+cqZt1JUtJlbxoqkCEZFm2b
8wsG9QKCAQAx+kn5XY41EdM3+dOYujGd2pYNzcOfe5hNR6o+t8psl4rU4aurKgoT
3I7LbZ+lIRjVC8Gxksf9REernZ06kAqW/6Nl6y1WrGzUI8po6wRzICscOfcgs+jQ
x8J00yOdlrS6kWrmMIhetYHyopXISxOa+rqpn+HJRFeBAhtHA5/FXMzXFHQryzhR
MTdFyTiIP/s3W07XLhSSbVZk2q/5E1BBJnn1ZAUcHb5SIbgnWevNmLac6ZjmwNIH
YQl4F59+W2cobBLGRiaHPl+HCu+FWcAYG5foaO4w3LUfZ/quQpJ25fHe2sO+DmXw
4sX5rMqW+v3TKzptfWlthyyZ9Wbf7p1BAoIBAQC4Q8V/s6w9uvnO78US75/HgO9m
GwFtbsWeBSYklvvPSmJFhZ0ESwNqrq1Ck6XrJ1wWNH9omI5RyEBItXQVQC5sd4qP
Ry/LXlXd0UWGu531RIkup0qxg4vBzuWKxODUh17xRu7tbSNkXbDv9GeFTUoEae0I
RGSjWmKXNpicmD+9iss18L3M2tuYX77piRwMMR722BZa5nEFqdPEQFwiB0jB+CtR
pQc4pJtcz/Dpt7x+qSrHKCk+1WhliCMFG0i5Rg4ze4gKabo9VlkkTkOng37fI43d
ZHDGxqV/Ba7BfN83er0MPyMSXIi0KJvHMOg5AFm8B4nfC0QkBW5phv2WSOOA
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
  name           = "acctest-kce-230728031733456639"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
