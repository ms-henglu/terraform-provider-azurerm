
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011150909853"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011150909853"
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
  name                = "acctestpip-230721011150909853"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011150909853"
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
  name                            = "acctestVM-230721011150909853"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5833!"
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
  name                         = "acctest-akcc-230721011150909853"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxTnLwykt3iuxyJ8tyQydA5fhZRD2FPhGLbuHg7Froo0MQaOKf8W2dpckBHxjQMpxv0je7cpqZ0Yyg2keuAlVOQwGAE6i6jAWaluX/Yf0wBLBZRx+8kYWPH4DCJ3RH5tKzCyX1DEXZXMDLxo5RxhL7JQvMs/5BUllL7KXpIsEMmyqFaVBsNLjIpG0ZE8CQd+OSzv4yJHd/SrapwGnpUjcaDKsqvg1qmgey9vg3bJbFH5Ss2DdRwsSWJn2nMH5Y+2CVCozyYpl7r8iEhSbN3YxOI2+C0PhSWv5EdbLjq0Uq2ZBXnFHceuuJNkHMbXla1BZwYxKYm2XoJl5DaPk1Qo+UYQKGo3lrOy2ZknK4l+ph5WVZtXJ8xJ9hDNMawtW9cy1t8ue6k2pM93cXF6pDNLbHalMS9nrnzTucJS8JHgvBmK4bH9J4xnS80JCA78AOh0jRUNub1/bJ9//2UayxpkEukDhCyM8JcH5YZUvjlVFpV1MwlvM0XAUFkXZ9q0DAm9F0taw3cGPWQyRnJ1EyvXiA+6sf+r2YmJRhoss2eYPyQ9eGR9mffn4SBPEBaQ8P/BD5MXMO9xOSDWADNoo/M0N6jzjZFGG4Vmi9JwQw14zvCJjoYB9Lc9gB8gHbPbLTi5bBaLwTRYOYpTM+7Q1VAPsYpQTbHdN/+Py4jO/AcmqLv8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5833!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011150909853"
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
MIIJKgIBAAKCAgEAxTnLwykt3iuxyJ8tyQydA5fhZRD2FPhGLbuHg7Froo0MQaOK
f8W2dpckBHxjQMpxv0je7cpqZ0Yyg2keuAlVOQwGAE6i6jAWaluX/Yf0wBLBZRx+
8kYWPH4DCJ3RH5tKzCyX1DEXZXMDLxo5RxhL7JQvMs/5BUllL7KXpIsEMmyqFaVB
sNLjIpG0ZE8CQd+OSzv4yJHd/SrapwGnpUjcaDKsqvg1qmgey9vg3bJbFH5Ss2Dd
RwsSWJn2nMH5Y+2CVCozyYpl7r8iEhSbN3YxOI2+C0PhSWv5EdbLjq0Uq2ZBXnFH
ceuuJNkHMbXla1BZwYxKYm2XoJl5DaPk1Qo+UYQKGo3lrOy2ZknK4l+ph5WVZtXJ
8xJ9hDNMawtW9cy1t8ue6k2pM93cXF6pDNLbHalMS9nrnzTucJS8JHgvBmK4bH9J
4xnS80JCA78AOh0jRUNub1/bJ9//2UayxpkEukDhCyM8JcH5YZUvjlVFpV1MwlvM
0XAUFkXZ9q0DAm9F0taw3cGPWQyRnJ1EyvXiA+6sf+r2YmJRhoss2eYPyQ9eGR9m
ffn4SBPEBaQ8P/BD5MXMO9xOSDWADNoo/M0N6jzjZFGG4Vmi9JwQw14zvCJjoYB9
Lc9gB8gHbPbLTi5bBaLwTRYOYpTM+7Q1VAPsYpQTbHdN/+Py4jO/AcmqLv8CAwEA
AQKCAgEApdaCark+k1lEZcDLXAnaIUJdyYDomxtkz2Gngmn2armVe8ALXoMeeTt/
krIRN1LDMKgSo/qXW/2fzfXfWbqnSY+9oBZ/UNJcltQryoi+mZ9rtRyv9gJPAlCn
NmCVjrEixOoeRNN+q9R48etoDEr21JiJ030jFHnxtpjCgB5QyiGrJwZNZWT+jnvc
Jph0+nUDjmmAOQ7GjfGx58oxcH8Cri8mF6EcZwykEKDzxRcLFQFfguvJRMqfg5b6
0jcdABSfiSvvXeGc8pMPEAr5tToSC07MZWaPkhBTX9ewVGlfPvx9rO8ttzIIvX0s
WnVr0r++qUvQ5FDotac3LewJJ8Y0PRb9rvHLDi//383RheViAWl2ZZTt3NatBp+E
KO29FL9ulLcLiY2DI5mgu1P3ZuPYL8ZcF5HkFLBV+hjXJhSTKarpfCssCE1fv8qj
VSXjMsiLkYC0LHgYSX33+gkQwLfZGaZlERFfxgMka3yoytBlYTwNJshKZmEbbM0J
S2hdpMAm1XzLK/fx+UdZPbuRYTBMwDdtlG6rtnWTx5CxszrDfl5wgzVF5Nlr0DJQ
DreMjTHipCzKHMArdlfDUXtBkoac5xVPww3vDSM4UK3ibu1xQvLidhZlmPVAsaVi
kXfeqecxj7dwgtOloLkdo3vP3k2xy4t59SBbQBvC775aEcx2gUkCggEBAOZDQl4S
tarXom2i893NJWzNDHguWYbl/gQzqNLVD1qGQ/A9onKBOD0VDUppwqAFTn6JpbUD
OZ3aIhaau1Yxukte51Piu5ur2CRf7GjXUWIm7L5qfNf0t090YOh0b98omszl0yfg
mcaeMy8jJRIYPE0Z3T3/Dr1eJ3fYTEskwktpWQ1/zRsIVCntdqU0juywSDJbBaX3
NhP10RqYI2ibqYuoXiLYnEyRJ3WimczIr8aX1X6LU8mGFrOK37DjE0sJc14kbJoI
/cUtcmniaSEmTvyarZkwnnfWAiiDKr5vJMOU2iaedyfO5U+P2npRqyoA70CvLo5U
ZsXY75KawU9ctJ0CggEBANtFN25zPsiv6oHkakmKCJGKKwMx4z+Xjic0eyK5fs/J
Qo+A9dSCiFsBkYQSDEN2Czsc96BfgnXFyBXG/tqoEwLyJxJc24z/40VyySky74X5
ZUnwo81cZU1/qBm8uIedaSzKTKEMtyOWwviMRG1j5QbSh4MUYhG1I41kRhBrEbyv
uitzTBIVywdWmulH6Ewnp6No9hgoXAq/FIRlvOJ/1ERRXajG01vCdbo65HbLtUwE
YTpM75anLhZm38OvVDpv/ZywBEZleMwJKD+vXlAsJ5I2v9xMymHlRi5uF0srRzWa
prLL5ljenWZlkO8/j6WRrMjm6ZtIIgZ5XmnG/hrayUsCggEBAMXJpGp2G8JCM22F
eYBeRPVuNHXPKmurh0RIs41WIjgZ+KWV68H7qTkeqinvKpSVulULG2GfAZDL3Fga
VSy2zlULkh0GNyyCscic9M8hlPCAiv8NLWu68vK2/r7ttWK02DOEfppUXQK0xTaK
M7+VPcbknpwwSJL1G2XgT7iEPLjWJv5nduDviIvzQ+SoftRkn79RXEqxTKxcjF8R
q+ihPUOPPj0kXy2NyZ1MLFwxTnuB1Is8Vp5WJY3Xjkm848eiuIx3MSom6wTCAvNc
3fzxkQt+OfvKPXSmSXhPIxotEiFF7RUbLTLujx6GbJ6BJEuSPfEMCSuM6DKuIyuE
7uOiuCkCggEAd16hJLH8tgh+5CPTcSGCNKlBbUXVbyM0skcx2d+eF8R7ReBw9DXz
wYeDDqE8p+U1jALjFB2qyi7YFHL2/1aMswfdGXQP2hzcP0yUEqe2GfuBltU4d24b
gCtE+m3xD3M0dLvVJ7/iW6+RiPnjrqG5ZxNpzoRkNzujlS/HrNx9FXmdIlZsTVQr
6VzOjL0my36zFpTnlJM0OG153/H6+Fua1W5uTJmhKs0chjvVcI7Jrg6cV77Wl+9/
eZabrs5eTkn1iT2Rtjk7n+hETxdLgt3m1QSVQntTmiPVJyWr7LIs3BPLOH8kcbEP
g1U7p+O0cfByXhTHjE+ipl+gdHlukHQXLQKCAQEAoniHnN2hhp4BOTqrz0OPYHqP
jvleAFFuujkl0A6qEi0DGJRYiX4K2JV0SpNQJpcf0ziCdomPIzL4YMXufzu1uRKz
i6+IRA7vtblScEjG0vBbks+zSmkDCHdKS8Lz1Ny+KOfx1gqvgwUjdrFnukQezebL
SxZGUDA/kEGeYswocJJal9MhqKD+X2deO/IA/Sc5GoYAwLuTJXCuC4yWqDgL94Kl
RX7q17hF5aeuz+a5jNKMM8oHaU22oGM2t4BCOnT4HkfXT8FekIy5Q0gRyITN4pUP
Q51Z2Icn+RM7DOFjCphhSD60jsQBdDbSPsQGmkvneHf8QUdyoM8O9PuUrQKpKQ==
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
  name           = "acctest-kce-230721011150909853"
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
  name       = "acctest-fc-230721011150909853"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
