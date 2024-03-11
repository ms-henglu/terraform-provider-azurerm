
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031337556302"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031337556302"
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
  name                = "acctestpip-240311031337556302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031337556302"
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
  name                            = "acctestVM-240311031337556302"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5599!"
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
  name                         = "acctest-akcc-240311031337556302"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyB8DydzGktOTfsAAtxbJsR5k2FpPDYoV4XUYPDwA1uuOqNHtLzzSXnKb0P7RaO91jxJ/bNPQYTyRky5JaFXWhJ8Q5zsHk8jayHe+WWEIg8/8ke5tzUNuzm9+v75o4fPUqOkDs/s/ckWmMZHmGmJ4nPAZ+kqZTEl8YzE1Uw536jkoaHbSzZE2Q+Biwn23tJhvoEEYX/avP9ZEob8C2JxJ94ApH2c87RW7uUhWEQZgvL6yybD8mJLgTAnGpAia/rTP+C0EWUmT9BkMUuJNoDsTkaYMaVkewBxvbuzaihZJLJYXII7hBeCwUvgdURzgsIowSGSNUlAcyxkf+05q9aJ5sa+Nb9q4Nd3aKHSRsfLXKZEoetqWZ1V+Dx6Y3T6PNxWUAc8L4OMD/mC6qvUORYgZu70AECAu9xff5fIBqd6DQDQK7w4dCgsttJhLbD/ydkM/1WMUh+d/DG1T+79tBMfCwlSHPr5eE3zWk/RLCVo/QYC3rohvEZX0ZrpjhOWb3rGoabhIcASKgVChvX08vIVbgZUzzURnRlbAWLpSQnH8ZEohFSziqbu1m1ItkZPeKuYFnDLkjj+4EryGS0E2AAHl7ZCWgIKlQsMOj5D9gNTGfq6QNms7lvj6TdRYhiTtUzg8AJL8LQH36+k8Id2v3iCYg0N9mhMd9FtlVeVfn4uXWGkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5599!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031337556302"
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
MIIJKQIBAAKCAgEAyB8DydzGktOTfsAAtxbJsR5k2FpPDYoV4XUYPDwA1uuOqNHt
LzzSXnKb0P7RaO91jxJ/bNPQYTyRky5JaFXWhJ8Q5zsHk8jayHe+WWEIg8/8ke5t
zUNuzm9+v75o4fPUqOkDs/s/ckWmMZHmGmJ4nPAZ+kqZTEl8YzE1Uw536jkoaHbS
zZE2Q+Biwn23tJhvoEEYX/avP9ZEob8C2JxJ94ApH2c87RW7uUhWEQZgvL6yybD8
mJLgTAnGpAia/rTP+C0EWUmT9BkMUuJNoDsTkaYMaVkewBxvbuzaihZJLJYXII7h
BeCwUvgdURzgsIowSGSNUlAcyxkf+05q9aJ5sa+Nb9q4Nd3aKHSRsfLXKZEoetqW
Z1V+Dx6Y3T6PNxWUAc8L4OMD/mC6qvUORYgZu70AECAu9xff5fIBqd6DQDQK7w4d
CgsttJhLbD/ydkM/1WMUh+d/DG1T+79tBMfCwlSHPr5eE3zWk/RLCVo/QYC3rohv
EZX0ZrpjhOWb3rGoabhIcASKgVChvX08vIVbgZUzzURnRlbAWLpSQnH8ZEohFSzi
qbu1m1ItkZPeKuYFnDLkjj+4EryGS0E2AAHl7ZCWgIKlQsMOj5D9gNTGfq6QNms7
lvj6TdRYhiTtUzg8AJL8LQH36+k8Id2v3iCYg0N9mhMd9FtlVeVfn4uXWGkCAwEA
AQKCAgAeAqiqyPTuZ9QimeCBlGVCrnApEcHxIdgOK2UrA0SM9l46auDKyLAzgbRk
LxJwThivD/MT+t+w9UhPbg2MG/NDiCccxflo7CIDFhHxjV+dhL83ky3cLlSbmJTF
ZGSOHeayPd9USkVFebRmkp6TLlkwD8GVi0JZ8ls49NQuVGkfMtsgb1FFipU8sJWe
3QODjaiPu7NQEMpPJG6+YsqmeSmOeCWyk+TLGQtByds+SlqPc3mUTXpT1xLT1FN5
neDAeZUGfpm8WhBZ9remZlGFydYxbVlHIxo9bQY4+EP9mUH38boeI88S9pL6nkKn
O1FmqBJ9iLa4tVLcEjR9l1Dq7Saafu6yVVrOYj3W7vacxKVIU05vwGWjvPN70Jje
TG0q8R7PTIKBay/uZq1YGGfUme7qFPOSc/j5mCJFjEky8A4+nn6ZrswYL+ZgMc/+
rr45CwHIxzYYTj7pzMJp+7UuYtMKmxdEI505QhgYisAQs70QXyzB9J7mKwIm5wPH
F2rT76gXmqHGwCT3TbxHGu2LIIGhjc52j2r8A95/CTWRodrnnZq4KoKRKSAbddUM
Zph7pGrvPpZaF7WOkYDqiaOStDxbxcvrZX0zIQOiSlDBAvxBSGdasYkOI/HTCJ45
mcWE9SCkOATCeLzrmM7T+UYtzOIW2+b6CII8Xx4RfUsShT/jkQKCAQEA2kGRTpIc
Pf4X90NtPBArLbASWZjjg/VXI5kloaLBRkWMoGhaMR+MF73EzuaF1jcWleDoqlh/
fnJuEYUaJdenlTFPua8yjlcTPYK6aKFn8Ljl5Y8xe+9eIlSToyUjNK2Bph9ZeZur
KeUBUYQ9qOFXooWy4Ap4H9aYYjIqm8C1gmlACf0U0P5V19iV2QTe0YVtCMx4Przo
5Wi09yipAxJhZClIJpLmZAiudWWvqwAOmb0rnb4W6PmlmDgzZzzSZ0dBFfDy8Xdv
yH3kUwzgc/TLIajaaFG6CET8RgHZnMvbGUMzBxcX8X4NxjhOjRl/VUKKY4uDAqWQ
RhFzP0yv1evYSwKCAQEA6rqXsguJtTaTpXvOrwOBB7WX8RCUG/KO0o333aQQKbMY
rWTAlORNBUUILJ37CdYJmPXo2ks5yNaoknq0x/SrWxfstUgL5XwVu3gkLDWos/ot
dWxYFA9rTlOFv/0ERTbelLnPhYgJhuZ1s1PIJ8mKhqT7Ty6o1QbwLTIhoQPQCRyX
HaPHgthZPvhU/FkMvnGwiecP5M4Dc1xbW0RoKld6mg4n88xiqQQ5FJ1QXM93IUno
Qnv9fA3C6piW5jaJ0ahdB1Bln/Vwqv6cFVR1xToy9c8Age4ks9xqz6JdIzEG5j/u
WYtphm/186YIPeGEU+8+1wqhBzCvEP4D5xNA+JpJmwKCAQB8XnqPvECtrro3Y0u+
uzPvn/KE7dNP4aEbHuzLs3PROFaPHYevkFuDN9cLU18Wl2OeWoAaeb2E7237O86P
m9jZ8jSNCeGULNhA59qTPs585M/URQmcpuUMSQesIsByByDm6dxRqLwbbmyW5/U+
49HNQcSRWEXlVqKU6iNPh7umqZUdXALdqOB/0+JnvRe/avmb1u/6SCmqeEUOxjOx
FWs76S49FN6GSFApg51boveu8ZYGGEjzzzZmjDf2bzkyMu9Ksnet0zJ2nA5cqOzK
Bsct0gtLAK8ygSUEO4+mgp/CQIG2W5mAOiVdO76/NrVRf05etSQdgPy6gL0cZ/WW
wAMLAoIBAQCrBNojUb66dhIq3sKextnKySbz71VJ63bdt6whIzjXePKA2shpctEf
BsXG5C+UYgrKFFjcOzTVvHhDiP2QNhZnH05KYjywrbCTzxvjzhClWKCoThD6RKW1
AquPTwQ+fZS8HYkyTARM8jpNNry9KF0ybp/feCpwU0bIVx8jVkjLarY7VSm2jnSv
qXUaCrN7ShAK2Xu+A8+FzIOPQo72Upg0CB5Zxc8YP8hq2ZdEl6+/ZD7Bud7c9JXQ
IO7IunG9fIKTIqN4YPX+z9TewZOw6A9bAr/m6qB5Hx3/O9fKHR1ewrOhMC7pUUeM
hqq4k0e7c7OAL/FU8MaMhdZIFMIgnyEDAoIBAQCrepFvsInHMe6sp6xbuPfticaY
8ceznWWiQCDKaGJhVQ1J7A+gMT+2EWRf4trISwYfdKQ3UhyDpBjL8FTjtkG5qm36
sfqYU2G0KMjCzXxdiVf4fNVJVyqTKQz3tbhwFUfaK2F8MbzbMSsqaIJRMmaXrRKb
U4fK12nzXkt6XwJB4D02xGXUA4NIt0F+W+5cJycGQRwWPXU5CHmLJY6EX+Y2JpCz
sRm6Flo8s+U9WQoyyeDKTBawPeNUUhIgsJVm5UA9tU8YHAEmxI5t9XjwwuY7cu82
pelrRbXZs6f9s9wBHEAxHpJy5zceCo8+fA8Tx9HL0IV803pqcNDF3eNJov0U
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
  name           = "acctest-kce-240311031337556302"
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
  name       = "acctest-fc-240311031337556302"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
