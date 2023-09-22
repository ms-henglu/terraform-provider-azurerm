
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053636525270"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053636525270"
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
  name                = "acctestpip-230922053636525270"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053636525270"
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
  name                            = "acctestVM-230922053636525270"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8837!"
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
  name                         = "acctest-akcc-230922053636525270"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0qanKF4bwTliXq38clKyYFxe57cQBq90QpIC87XX7Wv1ZmYKxtmUR6YV7VPIuM+y5RUw5pFcgP+UpRL1G5WCA4b/+bSxkI+2o465GUOvWjwetb3AaJMX8g6jF2f2qnwWmPQDbhGxKC3XWZeg/WRuERVp1Jt80Jv29xVGXW/V6tZ5/dUfAl0ueTHFvN+x+KM8VNvi5yGWj45hhPosNN6zXGLn14K1ql7C2tExNrRwo6nbzRK3R4cxuCVFVnJzHbalG49bjaE1Fc+b3g5vE0lDJ9/fhgmeyU0UHopnp3W9pxh6BbCwBHI2jHZtKMUdOwmBscl2OoMDkyHTKlbjbzA3+ZQvJ5L47gtuSRN1cmvVNV7ujBJ4XePYuC+G+MYS9uigSrIXwKfKWGsTY5lpYBIYTGTWWKPkBUgcQZsyHoYdieiKjw9iISe2vYxEjhrIGigV9ztArEXcCP7HyczGf4Y/t9x+oBh20xieBOptdTAUhsxcistrSdyisjwKh6d9UngEYdBXWQ9GEoPpo6tEtdQ1JEdGx5sky0TGgTlLWHNlR6a0Pzk+2nlo00F4StgmadFg+IkMRM6DfMRUjCfT5gT7Ljtk3n3F4KVVXp6wtGL83YfuqrC5NNrQ1AsAE4vYN+zhF75M31N9k78Oww6zK+iJnlwEqyNFIcxMcFLexKo9g8kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8837!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053636525270"
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
MIIJKAIBAAKCAgEA0qanKF4bwTliXq38clKyYFxe57cQBq90QpIC87XX7Wv1ZmYK
xtmUR6YV7VPIuM+y5RUw5pFcgP+UpRL1G5WCA4b/+bSxkI+2o465GUOvWjwetb3A
aJMX8g6jF2f2qnwWmPQDbhGxKC3XWZeg/WRuERVp1Jt80Jv29xVGXW/V6tZ5/dUf
Al0ueTHFvN+x+KM8VNvi5yGWj45hhPosNN6zXGLn14K1ql7C2tExNrRwo6nbzRK3
R4cxuCVFVnJzHbalG49bjaE1Fc+b3g5vE0lDJ9/fhgmeyU0UHopnp3W9pxh6BbCw
BHI2jHZtKMUdOwmBscl2OoMDkyHTKlbjbzA3+ZQvJ5L47gtuSRN1cmvVNV7ujBJ4
XePYuC+G+MYS9uigSrIXwKfKWGsTY5lpYBIYTGTWWKPkBUgcQZsyHoYdieiKjw9i
ISe2vYxEjhrIGigV9ztArEXcCP7HyczGf4Y/t9x+oBh20xieBOptdTAUhsxcistr
SdyisjwKh6d9UngEYdBXWQ9GEoPpo6tEtdQ1JEdGx5sky0TGgTlLWHNlR6a0Pzk+
2nlo00F4StgmadFg+IkMRM6DfMRUjCfT5gT7Ljtk3n3F4KVVXp6wtGL83YfuqrC5
NNrQ1AsAE4vYN+zhF75M31N9k78Oww6zK+iJnlwEqyNFIcxMcFLexKo9g8kCAwEA
AQKCAgEAmn0emrxqHou3WTjArBd6OrGD6OyZFE4ZNblf8NysP7OthivQO4XW+bUU
37lSvDeXO+sOsgppjTHkEiyVFmXPtEaN9NRQZXUAvXMuzRiWwdbVrvQ66Hb4WM3j
TocwoFfhOsu6uD7BbnYwOcS6jRvanSzXMNXX9CZuOUehE2WxvUkOrtpeo50zOC8I
ljx4iaEt3g5lmp1HjoEdhCj1wtCROnBPF/8EvK5CubgyH6y171HjocLYJ90+2Y58
C6pkQqZw8IVy36wbAqP/7Bsp2zsfxV6qz+K+UWP2HW/kFSyEqseItiOe86PP3bP8
2qm1hlayh3D5BHCRbpagB60xn5n9cfdstmEbX69Zg0ORK3GKkeIwwuDPug3AZDmD
8P2FgmyEZ1h+NBk9ynDRsbXKTI9ZAWE8GLwrlom4pGhUVpPtA9GK87Tw4o55EwOd
+cNqVo/uVIi/5BH3/bOcKiMB/AAfk28+T5hxnDcuwQmcfQoIFm1nnJLhu/KyH612
OhsftF+HOLkbNW3yeDKG0Iw9mF9O0STkaSjgxe5om2jqxAl0wj5F91p4KJPgUKsv
2HHcQsTwsAAbylXR68rMZGfeAjNmS1ALE7Shw3+QwlG0DDDd2gZZn8eAGXnkeo8U
g6qw3QzvgDDALLTQ00u50oBu8zovxQ7DQPQrA79ACkA2ihqNDwECggEBANefnZiK
uXz1zHgWmp9lCw4wJElGG/JfLpRZlTcuvyx45zlUexX7d3hivTC60XZZYoqU/At+
hRC/8bZ0XHuzZMYg+C3d5k6vV9zzFp1gtkoQ4+azRkK1XC71g2p1qSomzrsrlTI+
rhugU/zxbUfXGvkPQVjESKqzx0aaQiUrYHGXXpkdHcO0QGxw4V25O2DlpPhxOO8C
E1s4Zq+iDXcBW6e7vUUryhyOG3MkilgpUh9uLXWRQeEcGwOljnbMaurGvyU9tXl2
SoVIwI56U/jaEKDHIfPNrSNUo448NNmwi2K2448lOfazqnnw5Hh6qLTW/1B/SpYc
32YWez0vhyFLztMCggEBAPoYq0+OPmKIlFBEr495WczPQH3DVDGW7YQf3kRKJAnW
fpaPZB+wWbY0YuACvdqbtsBcqgQXVwbf/Isg9aPKfL96mvjXnrqLI5JsaP6+24vX
i13899A17l6DCFk3ybxrTJZ9/962q8JNKEajMk/W/BK3P0A2GEQYaDviQVN7czjm
PHtMDOMMVXlPJ8iG2hVcMU/pmCVvgfj81kTFWK8MmDV3te9j1gIiG59Ie83E6Hoc
cHu6BLVZZbC0MZFQi7Zz2CDxHGfnUcWbxskFIX8L50x2EvVWDLEE8X21HL13Drl6
7BZEzfxVSZYtDEuPgJjAmfCMHGvbms16FSA/YI3vGXMCggEAP3xfimpN8tzsNu9w
1z2I48SI6ooZ8GLV9BfsNzMsVovCiL62/uHrayanTZGz2oS23ta+3yOBSk05fd8E
2+cV5MAQUnDjPoeh9wwbvHqdMXGHqIVgSoPbgHgJGW9LP33toG5Un1aVLM0n7XGo
G17aMjqrotcoDhqgscj5cLg0zT0kPTC1csm/ri4OLOo88WqsB/pOKRETYehZU50D
GebsdZZxQ8yA1aeBrYU0toB0DY0DFXqPSxhbW9eC+rd1Q2sBHJXuuLR7fILPLyQV
VU/fVXdMJ9yG/cAN5/MSHIY+g/IVTjBHwLtllkG3A0IaKiSjR7Ay5b/ahtRXtMwp
nUQUwQKCAQApd0GgFSN+zspYbKr3DNW4wXwd3e7tsep7h5UgmXJUNz4R1IBzSJf3
P8RNA+dagYrRZgvCVeRV/Xkv0C0qFP6N+NQNAiMNJtilBFh8NETOcNRopvKnkOmO
vgb6U+ec1+WA5i8wS/U6Z/SPkatb1XdB2yQfj1iCodFWbHMMVmGKQ5IvlzJjyr25
OUiNVN5/wCNk7oQNYOmZ0MHt8RJ9I4dxBgIiSNlIzULrK+dq/ITXCjQUL4lsUAAu
RhIZ19LyU064V4GwMIg8TVGuLq2ZFO4qnUETcEr2Zq1rfEXhnAXS9vCB2LKWbcWf
oqRxOr/Fk9lyKqjjsSt/eghaqmdl4QjFAoIBABWgINa2fEsSnU1KUgiwQUr0vYLX
4oWqh9ChySeKKaix+AAQSIlMsuoUCtjek6Tuy/kuVhXmP5hl0ChSD7Vy+VRT6DYA
bQ3NsGY2lppWZr8h7PA7y6/qN86zm79vT9PueXlDxQINGT/FEdi3XkCcp6bWofaN
ONwzTki6aMfBkybYYnwXmlekBWptzmFeuo6J9XHME1uIIWxbyg80PGJfYroHxvdb
2zRBab9G17L/sQ0yAvi1mWAfyW0iPynbjeSXNjOUmxB6sSCrLnl+K8FaRO1Jxp5m
erIl6p1tz7mRx23ykS/fD0WRnFh4pHvNM4qLqBf6mRAoZa+Pw2BN2YGu3aI=
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
  name           = "acctest-kce-230922053636525270"
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
  name                     = "sa230922053636525270"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922053636525270"
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
  name       = "acctest-fc-230922053636525270"
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
