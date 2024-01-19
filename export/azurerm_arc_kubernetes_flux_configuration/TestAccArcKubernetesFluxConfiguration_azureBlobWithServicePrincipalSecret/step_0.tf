
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024520202434"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024520202434"
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
  name                = "acctestpip-240119024520202434"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024520202434"
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
  name                            = "acctestVM-240119024520202434"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5489!"
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
  name                         = "acctest-akcc-240119024520202434"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoWVM4W/CX13yPO1KpdVTXtLI5pC0CHbB8OKPRPqKo5L4BEwtuMI5XR89/6HnIqgShTKR4mgDdiU3ys+9P7hFLpE3s+DBaWTzQDCmlckTgadxc4De/dMJhWjfPIznbTsuZOolkiddVqg0BiPgAyVZrHui9gntgqB1Hh4mBJbfw5i/q3AlOrc1BiIS3ZbaaelbBy/xpRvMoXppRh58bRBjhmgLhklvSqA+o9Cado1V3WxrVCMbW5GwEGS82Nz21ot4fCFwwdFxtR3LvCOrM6VoG9eOFoGpssEqFZjwS5Z+NEuHZ6AddPGPuaOfFghf4iZ0N0Cc5kmv5vs7wv803ELkRnHRynVPH0pPSnyEVBH/pFzyQqgchqQlTvgn4OKuhn3IeEskMchjRLDHAhg92TT0nJd76ZuQHsSKPHPHcvPn0mv/mDVZOQB04APR8TtwKHs93gIcZobB2FxxJ0cl2hkXGZijFMRb3MDbRa7w2Ndk5lvz4jbVf6xVWV70DNjcyozjFKMw/WyFIL1EdhREGJZVL/HkdHtvlGiXQt/RSv/c+606tPWgZ/6Fhwoa55iQKC+4wekdsyMdL2AGwInnKF6QMomt3IP17x33Nxkz4rvqAY77jh0tmArTTSQUBz9mp2LOtbHABO2CdV8nUS62omlPT07qgkJ7L7BiTZ5hlkyy0qcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5489!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024520202434"
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
MIIJKAIBAAKCAgEAoWVM4W/CX13yPO1KpdVTXtLI5pC0CHbB8OKPRPqKo5L4BEwt
uMI5XR89/6HnIqgShTKR4mgDdiU3ys+9P7hFLpE3s+DBaWTzQDCmlckTgadxc4De
/dMJhWjfPIznbTsuZOolkiddVqg0BiPgAyVZrHui9gntgqB1Hh4mBJbfw5i/q3Al
Orc1BiIS3ZbaaelbBy/xpRvMoXppRh58bRBjhmgLhklvSqA+o9Cado1V3WxrVCMb
W5GwEGS82Nz21ot4fCFwwdFxtR3LvCOrM6VoG9eOFoGpssEqFZjwS5Z+NEuHZ6Ad
dPGPuaOfFghf4iZ0N0Cc5kmv5vs7wv803ELkRnHRynVPH0pPSnyEVBH/pFzyQqgc
hqQlTvgn4OKuhn3IeEskMchjRLDHAhg92TT0nJd76ZuQHsSKPHPHcvPn0mv/mDVZ
OQB04APR8TtwKHs93gIcZobB2FxxJ0cl2hkXGZijFMRb3MDbRa7w2Ndk5lvz4jbV
f6xVWV70DNjcyozjFKMw/WyFIL1EdhREGJZVL/HkdHtvlGiXQt/RSv/c+606tPWg
Z/6Fhwoa55iQKC+4wekdsyMdL2AGwInnKF6QMomt3IP17x33Nxkz4rvqAY77jh0t
mArTTSQUBz9mp2LOtbHABO2CdV8nUS62omlPT07qgkJ7L7BiTZ5hlkyy0qcCAwEA
AQKCAgBNC2OQ9l3OUrWReiE5WsWKrYqz7f3TUIWybSTBY+yMu1rkCk2FNkpV9tUM
1AfXVm5I4WQctVR5sLiae2K3KUr1OONjXfZWTpeEW/UZ6bwDF6Cj57ALcRPJeM+g
Qw8y6J50FAZNZ7c559+10qhcOBc/rGGVnBWiVuCxuOijJja5U5Cj0UwkZFLOk7N3
zkyDZJ9MpglvrP6ZUyswCtuQ4NLx1Xcy6plTAX4Fi05BK6UCp3/w0TV9F+X5XW19
BLZcooWok/oUu9vQ/uFD9a8DX4F8UQEGI22T5HwnhTOokbW7VxbTU+7b5XibwMzv
op3LAlpWCeUcVa6/z8yugE+GmfQIHq1+pw85ciDGxjlTe5yarPC+Ql81ituI8MxV
Efsni7X5GN9bDOzOzkT4tIu+2sqsZ+ezuu2K1pClSVIjkCiG/YWhMZUVJRO4T7c6
QIF4H8qpAFrA/fL+93hU/NRjsRSDBvXEjYkMqlXVcavg1I3AUPUbGxs8xAYJqQCv
tqa+Lgev3HZChOaeD9BXf1cn09bWJPaFJSPiCTU8FpgPo5gmA9RwDH6Bs+jmfp+S
ISCONH+GY2YNtidiJNxhGYGst0DjN2WiHsTNxhMlAI+Ump7EuQyKJw98UTb9qCuG
Avyx4qZpIS4UzKrYg1S6ke3Dx1+VoD0wWL4AD2LnU+RxWsK6QQKCAQEAz+sbLd79
zG85btf5qkxhqp+nQtG6d5l0RXxUMf67zb5uw3ojCUmTIANPV28Hxsh4q0o7RH3V
DL3lVeOCu2QhBgqKrk2qU2ZU9o5UEmj3BFBb7g7INGm05G+J+9VppFMFW77368y6
OPk1V8XBRjph3vuTS5hUQbbDa3kueJmV4mJVbT5iL+RGYduLUL9OscW3YvngnbQi
6fKAmTza9Wmi7DuV1hdu4zUQG7cofRYGEmu/E4W6vFiZVN9JUD220huGZMoDQUVJ
G1GdG1AMjf20sd4bwg3tfyMeSNlpCuJAc4KSvr87whaZBfW/V0UEmMNuwgc8NnED
1sJiosF7bVUm4QKCAQEAxrgGAR+43wtrigkAaSf0Hts78zxpr1Lg/ODFlTcO0ayy
e3GQXlTRGfv2sOWSPw0kYmLUggVaUe8vHHR01FCbNtXcuS3alCQkhoeB1O91NUdV
MgM3GP2reMwvWSon3MKKMIdKY50AzmHdeuRW0zR6I6aeVvrCPYieD1kNI17MtHh/
39a2FVl/uogwdaU/ort2RMpvPhfRY3uIBgQbXh8uZlO5kyM54OzC+FK0JRHn4HSZ
vimdno7F+gPYnkemDvmn8aiVl+YFStH1xdlixFyGaCwG4K/YO53c2tfIwohfLss1
pn3o42pQDWCv8Nthyts54kCtB1C93p/rlPk/K3+ShwKCAQEAnCoyV9nNNuezc5W0
aDzGfqk7r+xm6b3QnwArHQH/fSEzgI8UEb25S6owxbMXXC7ms4El0uPQSam3vzMK
1kT2qNryHskmzU1nM2jjrJA6OHtDESL5LKTYwVslgIlit5HDzI07GVjD5lcHwc0+
xcjECf9bOsRHRLRJQ0fZp6tz8H17PHpGtUH3uzhzA0stiEjA3Q5hrxHFx4HlJTOY
Igwd2uFGQW+IUg9g8fA38PvBw8Q52CfxgdXqFN1A64vu7RDPeJRirXuk1WgPYJxX
Ua7lMVNp9e8QGxX9gSoKw6n8TsYcAjkQYU8n0FosRRgJw9PGNOXKS/nGsF+ARk6c
rhnvAQKCAQAMnSHEcH8LqW3qFSgxhJe6XbAwgGU0+83MP3hLQHNwW8X4j/zaAAhF
3fiKwgfGeM8Wb6+NkUlqagRTihDgaT1w/aJFHuQBA0pOP8u9+HU4LI773bhhnbiE
snFO954QJUkgS3YtXInwj8W/Rz87qNkX6juiycgKn+Fol/59gEb+LafwTXDBaizx
ajOpRBQGAGBBfZgSGPDxn6XCvAAAuXn4hNgCvvmtjVnS6W0F7V0Kolwf9gRLTETE
2fmmEmY4DSDb9heIzNEJLsqrBGGAlV7yvdix6nePUTXzrj7QGlfwYHXHW7asuNLc
BockgshyV/gUpIZXMIjc2MnbavbXjAGBAoIBAC5kxJ5Eh3iKASqmps3gFLtBNMOy
HVsk1lONxXNw7A8vhobsWUdBZUVsHSVfCoQqH0NYJWL1sLc6OxwHypml0QZhe0M2
0+kARZa75sVfwtQFk+XWGSfPp1R59/tkGaVs2c4/Q9a27QnyyIIqnqm+nP26HoLC
gTRiNA3fj9IWntO6POC9EsaffsgQXyrl+pIrOxSMjeFKELDtMmlQ8quSR8KT5ZFa
9AOCo3ci7ppudoXkFyes8OaB13H5mO7dukt4IGR5jyGXc0MrVaC4dcQdq5Wzj/Vi
LneJx57QX1yw85WDKggt0hgFoG/AgqhZIYoFajjNN1robzQc6GP+JWzz2Jg=
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
  name           = "acctest-kce-240119024520202434"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa240119024520202434"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119024520202434"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240119024520202434"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
