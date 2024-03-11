
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031334070801"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031334070801"
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
  name                = "acctestpip-240311031334070801"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031334070801"
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
  name                            = "acctestVM-240311031334070801"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1783!"
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
  name                         = "acctest-akcc-240311031334070801"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5/Xf+2EgZ/9ZdVOzxCve2b84y3L7lX3GiuPNxL5qwH0w4QX9e6sWNGqIfVE9Wvxas6VXfEkuDKsXMc+eqjYIVXqpURTxE/s/FfcdnnfuCuvTn8heDJ+20kHtIB6/p5FVh4hNcSYiaIHOHoNjuRkegnsMusgln4CrqN3yExe15JmzRvfcj/BfwWB1kYCg98YlwdDdtRisazoDtwX99B2M7N1BQVOntDPI7m2rnEoatww9OtkGF42ScSVCVIuG+eeeOs6GpJXrT7eX7ujiekfXZu/MdHkphtc07/a3kgpb/D2vNMejqffcRsC0ya3BdFkqLAOJhxKFe58bZnPqXbI10VgkUpRooelSlwFKNXIdd9aNsvgkvGKp53YBflJJFA/LIZdI3GWbV1hUPK4Xd/T6m5jflF00PpPGtytc5+kl9ApqnMxagOxXbWTED0CLxwoxV5gdrSzHGPFIgfTe6Dh0pRJ+kgRDbxKW/NkQDLqivviVP0ktNYGCF8+Ekd90u8oUKXcy2AHAVGrf6kUZWM6AzX6aRWLQ2BrB3OUggRStSHvY97JwiM0ksufB9xMAXpC+llH0mzacMrLc+pAhskk68+rDlzeeIcM8/JbCOMwFMD0O+0wVTgu+QHb4M/SxEDdhSctNbVrGH8st3veDJKSPgSSpwTDijg1emy1DrO/w5w0CAwEAAQ=="

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
  password = "P@$$w0rd1783!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031334070801"
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
MIIJKQIBAAKCAgEA5/Xf+2EgZ/9ZdVOzxCve2b84y3L7lX3GiuPNxL5qwH0w4QX9
e6sWNGqIfVE9Wvxas6VXfEkuDKsXMc+eqjYIVXqpURTxE/s/FfcdnnfuCuvTn8he
DJ+20kHtIB6/p5FVh4hNcSYiaIHOHoNjuRkegnsMusgln4CrqN3yExe15JmzRvfc
j/BfwWB1kYCg98YlwdDdtRisazoDtwX99B2M7N1BQVOntDPI7m2rnEoatww9OtkG
F42ScSVCVIuG+eeeOs6GpJXrT7eX7ujiekfXZu/MdHkphtc07/a3kgpb/D2vNMej
qffcRsC0ya3BdFkqLAOJhxKFe58bZnPqXbI10VgkUpRooelSlwFKNXIdd9aNsvgk
vGKp53YBflJJFA/LIZdI3GWbV1hUPK4Xd/T6m5jflF00PpPGtytc5+kl9ApqnMxa
gOxXbWTED0CLxwoxV5gdrSzHGPFIgfTe6Dh0pRJ+kgRDbxKW/NkQDLqivviVP0kt
NYGCF8+Ekd90u8oUKXcy2AHAVGrf6kUZWM6AzX6aRWLQ2BrB3OUggRStSHvY97Jw
iM0ksufB9xMAXpC+llH0mzacMrLc+pAhskk68+rDlzeeIcM8/JbCOMwFMD0O+0wV
Tgu+QHb4M/SxEDdhSctNbVrGH8st3veDJKSPgSSpwTDijg1emy1DrO/w5w0CAwEA
AQKCAgEAtA4v5znlpdSY5HIswMItImlE9Og0Uj5nt7hNKcOFqhWDs6iqsyyC9/0a
JezB67an0XsvBdLoY/0K7Cd1yjpXDcNBWyceW5xTxAEmhLQjm2ajxwwJtVLk3yE9
qAk2TCSMd8BeHM61NtpL3XOwHSZagH5zyylByyZeGZ7vIdLt5p1IhHYyR6kXK0xs
9p0aVjsBZAl1j/WvISzPZWrJTo0Br3uwA72kGEV6W1nWNGNxiVV+0gdUq0PBwQJj
Eq2cALDCKnPWIDwfhKnGzjUIWFMb6VOLKX5Dtd+nv/2LUVmpPYvETPwLFwzHeERu
EX9HA8GS8sdsIeVGqEdBRa4E5uZGztdv6hqVNxyQIi4aVXrMn1hEMKkOnhvRnPBf
HOrr+nXMmrZGvYXp7vwuLq7J5lHtbzRnsIXZsF8yYhXJljHdGZgYmFczxmd7vE4v
vtZRA/i35COMzajMEtpQrnJfVmo0LwDGbFyrXHtsjkT+mTjvXng9Y/5ehnEZiqkc
AM+Zw3T24b1kGSxxg4qQ5WEUWKusjQx7eLwJ37fJGEVh/ZcNc6pyaxkBRXp+EH6e
wgUN3JjJFl6vGR/WwdeQMuq4iBhoYswvMS/7N9bPflfCQzgkjEMBCBWlmARyiq9J
fKjkqiAUh3kGvWAqtEsyHt1gJb+J3NXZHWWvx1Cs165pCWC6hSECggEBAPig+0iR
5BPLRZ4oODQX6CdvK+kgTA8pUARVNTuIOAHKR0BDKkNQTZw49ZKVZFmfCikt9qTk
RYF1bM7Lhu1hjZ6/uP2NrFgWKN8kYXihLzCjdmvhLlWNChNLO6DeKzVqdCY+fg4o
5e5LZ4Qn4+/K+EejoXps7uga5LyH1giC/wjIixBF79/WKM6St14l19omT+odz1+9
t712KWBX7D+knLTK1lsfYEwlU780psWr8HFqF4U74TRRQlCX8mZTzuwKqx+p8JDy
Bh0uKiDpbqhP2Z4RAb/5niBqFa8TigPCsFxQTJvevhjhMbkjGKKE5Nrt0Zt/Qvge
A12OQJfK4SSuBLcCggEBAO7WYqLri912k7NssJsMEn9lVii+6uY0GQY0SlOeaXjF
oYWDSAftSwCZeM0K4zKWdbB5bng1711sx7lNubwaVVM4UE3LB+Q8lCR2BuGkVORn
h5Tm8PvknMjLwPA29jXpqBn/CR3MoYEBBGU6IibzMdwUszS2L+VKEvmr93vT5A2c
01HXVfQMJenlfqhXaj+68eFBYFsQu3hDsIwZXTDELbsHGPNBEAxkkKbs4fnqgNlf
nFmjEZ2RbBCJLRCqfL3tCZsQAJdkcyi9CEn2cdeAVjiCU8WbrcZ62/ymfFtyZ7jv
NwIHyx8SHfzqJ8yGGpdFWjDFG3mjLtsw4/e8340+llsCggEBAMlyRadq7Y1MKcAX
flJW/HbXEJD25ilyo66fC16M5DQvHMPop5mauwdU70QxXvlubuEmqKy5d8eIyPxU
06IKZKC3Xr+xxm4opj0GUSNYFdAm4ZBPByex+vPfBRU2bXP+KNXD1IbMhGArIFhn
qbtkjP4einuTP484GxTWSoji+pi3RFWPFOgbsTyOi5vwtY+/cwiR1rAQG4ua7bNu
CbEXQxEJN9zk8zU/GTfXBTksMsjx2NTOy42EOWLrei+GwCVoD3a8TnpiXqnN+bxo
5ovhBsWXqf9N1N0WlzMfdbfOSu7A8RFpzESEUbFbyl4DpxnrjuWamzxFtRxcYeGb
NAhwJskCggEAHe800aKgFxPDk1tuDyDGOL1kvRqgqlWhRUvMfQp/walTgz5fCs9M
9ThHEbvpme+NtJ6jn+FyrMzzg2AghVjvlMycFAP8azjEgIVie2lzUmU/cwQ28/tF
Q012UyUwWrV8YjW62MdK/rY37NAKc8NLXoAhrdufySctlaleDWETVjlvqvRIS5wy
LEydQVAjevVdV5QwFXnVZU9mk0iii3grGyPalrJy5nq8Po+2CvK/T39SQ1HS5WLS
nofy5AHaPJu29n5c9JycamC25z5CKnZlWBPNmBjZAOVpKRNcxsFiCqXAyTpc1Poa
VBatAk9Uid0hXrd1qBsxxjssd2Juym8rvQKCAQAgWleoGsSiyVf0nUzZK2DVVDnD
Tr6hvuGbXGENnYdVkVENRbMzs+f5keKDX0uH0PjJ6xdOHeXRC8hPgEgypE9/uDIB
4CXM6PtyQ1F9FmzbW2MzDZvT9InHl6IGIMbdWQpIR6bkkIsX3DP6PtLA77EACtF/
dVjiYp2lKD6LcSrgNpSOdgbmFHhZ4KXTzcUpjvPXGlfrUE4J+SuzRp7fc81KFeQv
dZAgA+Z59wlZj4f9BlMYtLHeRcQnbQDwgXpRts9mFCcGOC3SlaUHMi48DhI5qmUh
pJmoA+6CwVSxEwAfM/qdG713tVkj8ka0fB4m+iSMUbm00Uz2bct17h3c7z9t
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
