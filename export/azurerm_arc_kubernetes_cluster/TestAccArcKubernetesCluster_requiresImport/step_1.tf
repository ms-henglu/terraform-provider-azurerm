
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045851974254"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045851974254"
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
  name                = "acctestpip-230505045851974254"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045851974254"
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
  name                            = "acctestVM-230505045851974254"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5155!"
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
  name                         = "acctest-akcc-230505045851974254"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuv92tqT3hEvEDbQySwllxmHwkN+nLNFJ9a+dTNQEfnuYr7s/bJfnn5RNE5POCJnDBgLJMn2u9aIJSMvl0SqU2uuCCtaY9PnzkYWQiR/LrVqypsBzE+ZLzfSj9p97N6aZlfOWu1QfzN1BETQa1CJNlsYjNYZs0IVp90Lk1/uaqPV77oTFJJA+DJkRspe7YHvVWCv8SaVh4oxWlY+YsehKrpT/7D235qotDyFcg3ASzmT/I0GHxCjSmF8Wbl3BF2tqQjCMFTCZXzJ9EuMjOvEYzONd7v9AkkQIe7VT+pumNgKIlciNe6FJ1kaC37Gm4oYnBI13Q4NANfjhf9MIsQ3OCn6kp/UxkPdajSnyukYb+Z23Xh8EQ6JlbjD8JCOGZql4oe1vnXP5AMPceFgGmaWmZ7X0qfVppvHJ//cKtV6s28Et9vrVt6eNMh0ob8Sa1AnSeRi6rqLgMzjlANInrpyTO/3drGX4iZlfvkvhyvMw63ulyTqcgsB4YXIGUIhzPHAamckT7igT76hDZwUcLbYHoSsvfgzOlwbyxfQM3WdP1L0tq1nCpLz4yCxWoxe2AbhnfhXIjdCuohecXnwFooDWoLoz81MNMBukwk0DA4wHo5lJM4aoNOwXBOkTn4VEJEdbHQmQ5x0nf+JkolcveAF1/RohrTfC8gl9ow70Rr1H3PUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5155!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045851974254"
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
MIIJJQIBAAKCAgEAuv92tqT3hEvEDbQySwllxmHwkN+nLNFJ9a+dTNQEfnuYr7s/
bJfnn5RNE5POCJnDBgLJMn2u9aIJSMvl0SqU2uuCCtaY9PnzkYWQiR/LrVqypsBz
E+ZLzfSj9p97N6aZlfOWu1QfzN1BETQa1CJNlsYjNYZs0IVp90Lk1/uaqPV77oTF
JJA+DJkRspe7YHvVWCv8SaVh4oxWlY+YsehKrpT/7D235qotDyFcg3ASzmT/I0GH
xCjSmF8Wbl3BF2tqQjCMFTCZXzJ9EuMjOvEYzONd7v9AkkQIe7VT+pumNgKIlciN
e6FJ1kaC37Gm4oYnBI13Q4NANfjhf9MIsQ3OCn6kp/UxkPdajSnyukYb+Z23Xh8E
Q6JlbjD8JCOGZql4oe1vnXP5AMPceFgGmaWmZ7X0qfVppvHJ//cKtV6s28Et9vrV
t6eNMh0ob8Sa1AnSeRi6rqLgMzjlANInrpyTO/3drGX4iZlfvkvhyvMw63ulyTqc
gsB4YXIGUIhzPHAamckT7igT76hDZwUcLbYHoSsvfgzOlwbyxfQM3WdP1L0tq1nC
pLz4yCxWoxe2AbhnfhXIjdCuohecXnwFooDWoLoz81MNMBukwk0DA4wHo5lJM4ao
NOwXBOkTn4VEJEdbHQmQ5x0nf+JkolcveAF1/RohrTfC8gl9ow70Rr1H3PUCAwEA
AQKCAgBTBG0Iou477oMIbnJRe8eSLhLlzlTigbuq9h8IZ6vjFy3u/lsm871hzC33
vgufJ9w8A+qcns2YwSoMBnFtzdCt7BYch676OylV9oz3Q4Vh3b0oaJHuSLRop+5O
4/iI+U6AEtddLPi9M5DaeV5bxSra//XLonUWkdQ8cJc2B75eujUd7BW1qM/TOfVw
awpFyFQrw8NKUsDFGfaqiUiJ2w2kugNwNuo43l4ItI/kzlGbDZ1zYnlKrbDo8nX7
42WA5zASWIkoMx4z9C8wvmP6m+SduWcPXoSlKsz1VsgEnytIGRHYJWQiebVVCpK5
ip4DPPl/fOpwr4lHLMm3vNHEANPydFAGA3dExd1uZugC1Zs4puvWRLMYnv+7j7Ma
JdvbnjHkuamGGonv2PBl1tk97UX0ancky9z4iczO1W3BTiHGfJQgFQ5812ZFc5dU
876zuqcI0JP6AbCoOFj8eDk1smO1mHO6YXncq3jf5GoYmxVyjAPzQRgu3mwwVPmn
43Msr6wt2wf8RZymflYkkXCV6bb47S9bhkW0ShWanFZh5zjgwNiG6PlEyqXlgT0l
2hEUtS0GsGAFp5LyW/fB8XxRQnxTWLVkiUZWAbpH+nxQf2tW4quNk2+D8VSUsf44
bdQz+qYJ9kWMCYFTxVoTUNhsR0AUo3jj8+3sq8dYn15rjTxr4QKCAQEA5WMBBFoE
R8HSHcXCbzGENy902iNNuthL1Z7CkxIgq7rbGVFsfyz7amkAEH/kVf0ZINMTbjP/
zsQ5G1r9jWDAICVnIKZ21iujp8iCM9FrOvRi9KV+Ejq/UjAMZmjEVXAvmQ3kWu03
THau/pzN/JeYwKXRN5CZUt1O4JASI71tb3545Dsk7vLAEdUdRC92dVhrdLn6xdVJ
8/YEbv1WGYLwlOeMlFzvjLYYxdMbYRqj8kMHMmGm2zOZVgtQ+eLWjE5dbFcNy55f
vpRWrTvPOKtBVUVIVXfOdjTci68DR7Tpwj5sN1sTyPegt+xhoYaTNfx+ho6/UIzm
jGJFyZfsv8p33QKCAQEA0LF5BAeUdD0E0DwfMyKcKqapRVwGqlFOdhbuRkERt56V
9JMKdgqn6FvAFXynOocb4WBY5s0nvdVwikrr+AUa8suCoouElkLeIeucxA9ofztk
rF5fZ12PEBytGuWRncQVYDvC5OHBPbgMJjq/BvbScwEH9HIOlrsMpSvVcxq6rbfJ
gvZEnJvvvnEmBofDt8bUL5SOsUdJ0gtq1/ryNBwiE57pISGyBY3Vg/dftBUOIBXy
mGmjahOWdgB2psNME2JnPy4W5JzmPJgb1IhvJc+lHBvraYbYQZi5FPHaZz4SDAX5
yVquSR1tVtEdSVcpMwPopAOhAOnTIF4m960Us/Vz+QKCAQBatl1HmEWLDwYFyhgL
GvzbSgQe48kwc6sBrofp20haQUm16HJMlMBUI3PoEnt82dtfFLnhYeTuosCmpcQR
bcpsq/3tdocWSSmuB2geD9ok9VJQx0Vk9iCE4wV0VkgWNYhNMaY1owu0TFcFz4LS
Oi0pOinTnHZVw7kWq0LRKW8moVAziYQgjpUQOEQbm91vqGjOP2IBbEiTlp3IOp0a
96ImcK8yWNJOxhBj4wk3zG47NvCYpu9yTiR8V3tNZrxLvg3J8188P8RDPKxOU5Gu
KmNq0jw5uGhIbL0u7CYS7GNo8oCfH4BigDLpqSwu0WZT+icbFUZpF19w8sgAYfk5
G1ttAoIBACEblqRCA5YxO/tBHn4BRp8pk38Sa2hHv9fSKXjxx7rGqOmFDkrNw/eD
3sRJ40nQt2aY32G2OFDQdKsr2aWeQbk0+gOJeL5R22WsOFGOVDijFoSV8DK40AJx
WjEDLIfH3NBIitG+0uZUtXC3LykOrTJbfoSUN6ZIBGiLvLAnFGiM2KYzJY1m27Dt
yGeO0EjufSkTO1P6iEaPUyLyh8wmjm1ob3m3G8PvzWjDLOan1HbYpITzdV5Vvy/3
QNuR7hbBLLoEONOJ5KjGRNwBzQhFmd8Mutsh7lrxvKMK/2gTm89Wf1snTLECvx7f
y/KfpkSWoSir/rXjYoAnD62JQtiN3xkCgf80gMqXUvnPESBgvYkbp5XbcJeSHjd0
pHsA94E84/Gra3RZ6KS6vGarun7Dv1Todx0J6bCldEbMOvd59WyCl2RGJomNF0vu
DksVvriyxGSNv8E1cyWIMLlVTMBVetBzFeRSCQJsOkr0y7crruYf1koDg9lZfQtC
npmhKLJNJvgCNBhJCzHD81g61+XZXswFrSvtsQv8yOLoW5iipUc9nFc/k9nDmExn
LqCTn4P2/uopbS0Z2oe6SsTqQ9jUanYPjNEbRZoFKyOSpVooM1GJxYNqpns5lPum
pW9kFiTdvriqDawA6Yk18UNyM6/JPkRj4NN2jOXa6CBRnbL93tBAdq8=
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
