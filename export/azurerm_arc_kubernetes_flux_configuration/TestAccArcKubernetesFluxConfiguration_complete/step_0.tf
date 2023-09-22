
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060605991952"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060605991952"
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
  name                = "acctestpip-230922060605991952"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060605991952"
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
  name                            = "acctestVM-230922060605991952"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3849!"
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
  name                         = "acctest-akcc-230922060605991952"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtbi0/Y9b3gHMc5jZpoxEzMPe8xIEFd5OP0TSmVgEsbZMfD0PXbSZ5A2wMAqZ4yJab/jObJy3NltsFiyT49AA2A6SoJkHDeC8VzTrxf6vxjSS51YJmfQdUvZ+s0/UKh6dumZAPLsf6BKmwBFHLnNsvyHOfWGPe8FZg/uFtECoTfM9LLC8bfxefvt0+Cb8g+CNyQ5WcvHPwg9hLpmTHJJABWjocXXF37TKPUoROMGEnbX8Geen6VHqjMpGQHv70ySpqy6mT7cWNGfACZhhsQEV3/sa8qo87AlwBCqAC1HthKbRUupknm9RUqWDmuRt9+Kr6g5qfax7Xr3FZhtSAbR9OtxHfwjA4f+xuPUGhDqXzGvRBOqMbi7JBgyYHOjjasGBmeqPTBOK0T3wmyHamykjt7KePYIULHr6JpOEeaZGZ1+dQEcbgToGKhvELVCNyb8OQS/jTtNLrho7mejZxXOMI+R79WRH1KRtB5MzLTxV7q9PDMnvm3Lr4RMF+wDXZEun1fzkgrsAmYo6hr/VIDPxGMvqF/K8I70G4fRSUSNxDaK/xG6JCDzaL25+ep4Ak3yKMWEF54o3h8JdPA6uq5Qjp6tzGugfVnk1F0wVdByJwB0z6+PSjlxRah6e4e33Exe74m71chIY+buuNZSTIqHKolacmge6q8U61PG2YSAr6CMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3849!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060605991952"
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
MIIJKQIBAAKCAgEAtbi0/Y9b3gHMc5jZpoxEzMPe8xIEFd5OP0TSmVgEsbZMfD0P
XbSZ5A2wMAqZ4yJab/jObJy3NltsFiyT49AA2A6SoJkHDeC8VzTrxf6vxjSS51YJ
mfQdUvZ+s0/UKh6dumZAPLsf6BKmwBFHLnNsvyHOfWGPe8FZg/uFtECoTfM9LLC8
bfxefvt0+Cb8g+CNyQ5WcvHPwg9hLpmTHJJABWjocXXF37TKPUoROMGEnbX8Geen
6VHqjMpGQHv70ySpqy6mT7cWNGfACZhhsQEV3/sa8qo87AlwBCqAC1HthKbRUupk
nm9RUqWDmuRt9+Kr6g5qfax7Xr3FZhtSAbR9OtxHfwjA4f+xuPUGhDqXzGvRBOqM
bi7JBgyYHOjjasGBmeqPTBOK0T3wmyHamykjt7KePYIULHr6JpOEeaZGZ1+dQEcb
gToGKhvELVCNyb8OQS/jTtNLrho7mejZxXOMI+R79WRH1KRtB5MzLTxV7q9PDMnv
m3Lr4RMF+wDXZEun1fzkgrsAmYo6hr/VIDPxGMvqF/K8I70G4fRSUSNxDaK/xG6J
CDzaL25+ep4Ak3yKMWEF54o3h8JdPA6uq5Qjp6tzGugfVnk1F0wVdByJwB0z6+PS
jlxRah6e4e33Exe74m71chIY+buuNZSTIqHKolacmge6q8U61PG2YSAr6CMCAwEA
AQKCAgEAjJCRv8kSoMn3YjuLsF60IUgpvw/ihR/umtYbqW4CQ4zl4PxCVJOMrnFA
JgktPBqophBpbG5U8gEJvKVCyGdvH7E2DnAQmtWKGlLfRcpaIREtyTAuQR4pSLFP
FFjdnq8MBtFtQwzkA1naDpvO2cmDBt2ZojbDDFFlcsguhl21UoaifV1AhDtAxSyx
L/rIPSKHykwC5urRcCUBYVB+EQ234/dgRdN5+i8YeQxAAgz/DhdlKIyev8YTjlAw
w1SkWJD1hWqSTvsqe+L9Eu8CMi7KwvSzxZ2VfmdWdIKDhT4cYg2/wUl6B2vIFgvd
nwSvY528qVH5Ybj3vTNB7FeZuaPpcT4+CXVgbkbf4UKxlWdnyVduHeUlbVOOx4Ed
BXZuJw5fQStx4QX3YPMChnObgckNQ3a4yiLK1Qlx/DQ6IlJ/VZT+9HLE2SXpDC/i
D4mcgfBcfXqYV7+pmBVWH8LmgN8qj0FIhH/X0TQ/bKHckqMEVL6HueciZqHcPTiA
CaPdSM2QZleptHAT22UXdOMSRrH+dZqD1bdW8zX28TyivEKLgrf2+QVZbYQrCoHo
jM54PTFRmR+69lpHqNtL9KVP+HfM2DEuzp41CLg0s7YZVAotwtI9wBmkTfVlAsJQ
KB9eoixLib4EYq92dhcM1xPvxW4G5XjpG/5/8b4ICE4i8UMnoHECggEBAOJVZB+o
CPXqrggFkplmzFOVjb7U1h5DAhBBW8iBXj8uDj2X2OO3NyChI8KfUSx9lO/zuOBp
xnRf9vhJzKH9PTT3F6BxmtpVZYPYb1ce/7QCopAGhYga/zg2rWyINHwf/B9xiRN4
cqXdpcQrwdqunwcsJsAWNaceahlrFfXM4csm3r0wsiakNE0NxHIu+XBBhWH4D6uy
aMHE94+UqwdRkOlPbi1i9faXM3T5YtcvmF3jCC1q7/faGpo0jE2lUuM4eQvOasIg
IAX6zJhOZnRUhd32CdpJfzQKOBkFJvc7izclLgCFNooMyzOBgsZ8De9UXZdzp7JZ
ffkW6B31Ti30Lq0CggEBAM2KXIBu6PqtcGAjJsUXGcW4M53ouiqpSfKZmidx2Poo
uYZ4jbMaGBZnoLW6A7MRB5T2kLuys5Idr/QoB2Bobu8/1I0f8mtGJMobCEfERr29
PvGFNYX23OxZrQX3uC+MzlEBTde7Xqk+aEvgdkLS9CNU3DT+fD8l7wSG1fRaKeRa
xM9fPQhOKEq5eD+x/+tNNKcILhhp9WoU/E14klu2bCxlfq6y+sjJ8db7uMCer4Ex
X+ppWzr9y60b2ZdXY4oZNP8XdAoQBjJwuFoWAL3sbEqm0XyZvGvSHhkt7sxmgLOl
Xpr88IqEKON7efMCw2Jwg6EPP4StZqY/OSP4gTxTXA8CggEAVXNVzNndIDNNJzwr
X/0+sWPqUxz6BgzYb5itdWLaWVIjEEAPI9IdXxVXcfhCZmC3ZWyH5ToqMe+1R4Jd
Xt9ER4XuhqW9iCbrn76MMsFCWw0PoP7FVWCT8P47tZkq754HyztLPG2iI1suZYT7
uHtrEQMrUiRQd1r1Rcl3TgjfSprPR3BmIk6mbF0BSPbRN/+Uwysrh3BhOp8JtEy1
0ZqK8nsJptsQ79ugEs7A8WtHxFKd2L/h/5p5prSmL/5179F3aeyxw77rODa7Hdmj
ttHehLGKgL505wngqhmW34q8gcJovsuMjsxLv5Nq81MM08nvV+nTa3N8Kxnp4r2l
mZXyNQKCAQA3U5wssi4idBdAuZWRDfPRBhFW2zNpkmImXHRjU8DtLZMrAD5cTJTZ
SxG2eRjP1bCtx2UUMTknBri7Rx8dM19RJWRojIXrnFkA0h/7eXj1UACmcI4Evnuf
X1A0wAajPgq3QVuby4LimbrnWcdbm38+F3SjCzGUqfhZxpXHDZIjNs+tZlx+ZNNx
sdUNiDN0OjcHEyudRMBbysRTcjYrW8JofPWJvwHElJ91mBKWPuDNLOY9qhh1m6V8
tnduxoYzwS9DzyNcJg4U+8ST80JF3WMVASx4lsViXI/fhT63ZIwWT1hU7estzf9X
pIAiCsdfMxwreXhGlYqBC5ms9hKLk4C/AoIBAQDU2h59gS8Xqt2gm6ufKxfSIMmq
4Li3Ri0cGnQmL5Ya5FYpqfEdmbbn3JZb4D0v3zKMCWGh5BqyW1HUCEbqRlWldZ0W
dxWlGCU5Ycyoje7xLISMWC2qqnXVhwI1gwzexqj5onxZVtMQmpi0zf8m+2y3b3hC
zzmsYZvsCgXg/0Yd9o8PD6jN+sdKpcIBEVdfO6mq8wR5xNbrW3AAWMQni4FsGdCI
MbshsxmPGz+/E3vpf8eCyWWtOIwEOIDDzeD4cuAjJfP5I2ZAb2hTBUir9lnM6s4W
J2oaD9HBc+w7TU6U42x+8DwzEFa2MUWyOdZ/kRyuMt1zbsKrwDaRkFCAzleU
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
  name           = "acctest-kce-230922060605991952"
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
  name       = "acctest-fc-230922060605991952"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
