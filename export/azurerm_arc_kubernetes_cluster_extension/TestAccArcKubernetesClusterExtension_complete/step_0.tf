
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022854965399"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022854965399"
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
  name                = "acctestpip-230915022854965399"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022854965399"
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
  name                            = "acctestVM-230915022854965399"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5277!"
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
  name                         = "acctest-akcc-230915022854965399"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtLK4bCZZsYF7VN0vUQmN6aC7Bx7XFSFOxILRFCPtBcHFCeAt4EA4vqwDQRgr/YPt5LzxL4foTbFCx7GJGsQVkl1XquhagXjsRqiM1lhylttkWN2AmDydRK/L7Zy40qv4uzyHpfmhFVfQwTtTYlhdxcP2A5Qy/p0uvg8TVkHvf4FrVoMlKhAGqqYYpNfcFlJ3Y4Uop9OaNEenbTJej4ejt9eQ+e5/S9s+qW3cH4SDSZSY+y3yLC8BdXTsVaS1lnO5P0gJDKDJxBTahSde7lrq2f2Z/DMM0i3lm7SNonMBKXPVB4gqcyqOqtD0xsENQKGe1bexlXaB6Ml1EsDOlQi5FF6WzYtHclB6nDIsLhcLOZPNZzHheHu8H2P+DrM6bqoUTAXNyd0hJLGY+UJEyZXOSG/HFHfYyCei0xYdSdl72TREhdvs2wGv+p8/Ntul6joHG2KWs4Ugu7TKCi+3jgRIaFdnr81lBb8pAikQDd45IeMsuzu2Oo2N6L36gjU7mKxietLbvTdSbp7MK6/7KKNPSR+hDgLrtbRxAUH9YJDsD743hjllotuDOCHggD3VDZkJJFG+lxvFuWXLSgYAxInht58u2Lsvll+XTASX82YNY7IiiBNo52Qa3ktYMxy6Bh+Azi7XRb3A1YerRZHG2gyIjjzlTuW1GMTPzX6Ki/tGt9ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5277!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022854965399"
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
MIIJKQIBAAKCAgEAtLK4bCZZsYF7VN0vUQmN6aC7Bx7XFSFOxILRFCPtBcHFCeAt
4EA4vqwDQRgr/YPt5LzxL4foTbFCx7GJGsQVkl1XquhagXjsRqiM1lhylttkWN2A
mDydRK/L7Zy40qv4uzyHpfmhFVfQwTtTYlhdxcP2A5Qy/p0uvg8TVkHvf4FrVoMl
KhAGqqYYpNfcFlJ3Y4Uop9OaNEenbTJej4ejt9eQ+e5/S9s+qW3cH4SDSZSY+y3y
LC8BdXTsVaS1lnO5P0gJDKDJxBTahSde7lrq2f2Z/DMM0i3lm7SNonMBKXPVB4gq
cyqOqtD0xsENQKGe1bexlXaB6Ml1EsDOlQi5FF6WzYtHclB6nDIsLhcLOZPNZzHh
eHu8H2P+DrM6bqoUTAXNyd0hJLGY+UJEyZXOSG/HFHfYyCei0xYdSdl72TREhdvs
2wGv+p8/Ntul6joHG2KWs4Ugu7TKCi+3jgRIaFdnr81lBb8pAikQDd45IeMsuzu2
Oo2N6L36gjU7mKxietLbvTdSbp7MK6/7KKNPSR+hDgLrtbRxAUH9YJDsD743hjll
otuDOCHggD3VDZkJJFG+lxvFuWXLSgYAxInht58u2Lsvll+XTASX82YNY7IiiBNo
52Qa3ktYMxy6Bh+Azi7XRb3A1YerRZHG2gyIjjzlTuW1GMTPzX6Ki/tGt9ECAwEA
AQKCAgEAheOnIvuHmi8G42rAlJsvu9yMuEnxtIZphtIneXTlO07IYPjrBS6Q3Tc3
chQnBEGtE7+sNjvNtUOS58R0gpCoKzteqhRge27OI8zgDjKbNYx6Xh5CGotPPIXF
5NorWG50bsf6+tBsuxPGamc68bPoR5FbyGsXHfH5oHorKc7RVvjeP8wMzY3yYp+P
wxTuzttr+yG/bhssN3CgbhjUWCV4+c+QbKB7Ugmx9HiikffuD6c7c2In/vUVb6Kj
OxJAOqqkqG8HxYOd/Nw2zlLN1G8pdTyjzGtHJLU9XJH8IFJ2mfBp+Jq8WXk/HPKX
bG2/FBStTE5AFy8oMwSS6sJST7uW5nFIaVCW2EaYfO1OlXr2JIUAmRq3i+E2z7NQ
OHrY6Dd1n0mqpQWrNpG4/1hMUuxD8bldQbUEsFJ0Ko1IHwHCxnACuwp1tbZ8RAFt
AId44KcpTy8z1gCuA2fDJ66zM1SnARsnx8G2LDmrHBb9Oai7jxRQT86hgQiq2rKD
HVDeUV/UNBJS8yCpNkWezunfjJxJBf4APv2S2iJiNf58Fdi8+90WSWrXAwbo/sNi
8KhLi6e8hvHuiN4Y2C6yzcfpUsKqxV9eRp8xfdNhbPkkYAeBZGSUiULVObO4qKfJ
ga10qGpWmmv0FtCOAwgpLNKl0QKjyQlQKTGOI8ZqMGOo6eawtQECggEBAOgTZOCw
Q205YOeMxM+UjCIG5+Gt6LlkjmBhueLxJZogRpFSL08JxDsH88V7NSziby38a47o
MuzE1Oziq7fG2ifCnHrh4UKxQpyDMeAPxTTp/iJrDyw0Z4Krpqk1lw8wYJJmetlh
/+KvhiK+FIl1BntjmD7SfUoRtEiX8m+ylNWolqP0A6o4hpFqCijLKNxKkvuYCD21
FmwtX2R7nLi2HlGqHpWITSd1T1sOpmBTJvEOIfZqatn/VbwGjvi2ANXrjDKimsnb
ikgyWduldChvkBa4omZRy52g0OfHcUIX0NBkS0FR/fS/yy6j8585loOXnzHJLFhk
ySU1enzB566EPzUCggEBAMdTcU6QjqM6zXAuiYjbekUgrTlW3n7DnPA19BdNEKF3
khGoUNUHHgMYOkiDgrxOdqq6PNi2BDIn0G+lgf3DzGyznpN60mAB3mbaCZkviHex
HR8W8u/jHQA71F/8rqDxc88/nCWJJir3DNdfd2bfpehWUMuJ0yQLaYcxuWtN9WzB
ClvpIUgfb9xZgOGeNZ08XrfIQhdxtdw7Z/99GlyKLwe+YKIXS0FGpXwpYl4TYfUd
787bv+LJ5hyYIOOroCD0L+zofQydXMm2bOqwvZi0yozbx7F8AiuZXW8cIvzYlSKU
g+0w6qOcpVli0BJWauGmuq2EoWd8kPhZVuX72sqjHa0CggEAZm9BBIfoiwpbgni4
2iLoI5DGwu8fHM2MpnAcO1ZTUY9Tdos/BHT8H04oRA9Y7kHX7wVOeFp3N9i9Xv3B
67Ei04/rv7V51xUkoK6r0glD81Ig8RIuNUXANoYLXv6feX3R8my3ZsIBzw3IeAdM
S0vTG51fMsN3t7zOxYgD41eAqDnsm9t1zql6hC644z6g/3MPI2v8nzgR+JeiVljV
WRZRlZwwObJa08LMzxVNTJEHTDj/tqNMHIK+VerTKmYzQjjgvezVw6lahPlsfi2u
crajc9P1IpKR/DZiXxvCGvkmGwVZzjAhlukdBq4pNyuVCupewvvXzgBWZE0RjoWL
/JS0zQKCAQBsZ9JY8z/QQLvYhkbgutU94W60n600bjjdX8qYHZ6s4nX7ynnj0hId
hsC0DWo99cKOSemrxxpzGLpA7lfLZwC4Idxdw0/FTV7iuzS7LmHfDuGStg18MB3m
saNobOmguJDOp37J31R1y5UdUVuEBKCbws4AVL4TfW1wTLfWRzjyY+65XApwykAx
LDBvBHeOQ3YUKALh80MAOwLtreF3cOPxJzYxEdAo+T4pT+yi05HUGOsCqvsqYboX
1RkWGZJmOcgS5cKU6MS9I80KuwLymWkLwMBTo+keQzPQqRHSSAycGP/DMXZ7c0du
XNJjFsLcZKxkkJyjxtilaRlczWQKDzqlAoIBAQCsNFpvViuWD9nVV9ZyR5u1/htT
Rg62/dxvcs15N9J1OhihK3uRgmiaqnIO9EYbffGbstTYkSBHD5e37q7n2tO6SrZP
QztOMTPkNTFmmEqDg09rvrt+yAdehgF6RpH4axb/LwQ5MZJMpmtYQutLRMDIDn/A
rwo1QaB6gDsQtD4iwojwTLD2dLcfCXZ9a4PmhgpvuwjCFV1x0mOKMQMrCKfiHbj/
ZDoEwxsBAIjrtCy5RydOT9kVm7+H/55lxUXm83X4VoC9H4Oc4nydt+HidFVUMnm1
WlaLYCbEZWHmBRcTDYKw9B4v/aZbw1EyuRKInfyT0FSK8qDPGPc+EQY3CMYj
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
  name              = "acctest-kce-230915022854965399"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
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
