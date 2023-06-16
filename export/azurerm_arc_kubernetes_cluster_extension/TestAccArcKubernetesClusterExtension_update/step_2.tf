
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074250140134"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074250140134"
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
  name                = "acctestpip-230616074250140134"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074250140134"
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
  name                            = "acctestVM-230616074250140134"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3536!"
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
  name                         = "acctest-akcc-230616074250140134"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0AmZkEIR1+KRkFPxvwzt9uAt6odP7F4gc+ssOumdGL3DETL8QVb46549aHe4Wd/+D661qPGsqhFwnsD6f13jlk4qXZTjGMiMlh/MHZlFU7kQJMDsrvjOSA/qhl+htRE/vlfD4XI4JZZyyobw8kau7vp7pkOxZg5ZtTmbzF7ZyuLmWLodCN6DA7TUES9JDEijNdMkOuoqKk2lZHblA2rmeogk0oTOsFYSCEkqW1hv7OZxnzt7rAaV83dscb3RsHvJWJgFEpURE4L92eLxoS0QrqJG+OuWHGCn1R86YC+uDxq6uIZT/KvMpwEypaNbA9sjUFsy8xwloFz3qBISwrRZQH5z5WnJS9Xjiw2CLeQozeGmLAy8iVq4M34WJ3EP0xJmwl9Zim+1IZIGKM0/L2PK3xH7UOpcVNttey4zwrB8rCgWu2qCvLjlzNnZxwSCpZkWE7JcS4/py0mEA8cTrfCJ0T+XnMkITDDif8VxclOMJTvwZm+MEypROAR6yO24TS9O5cfsDZF3iiAT7gQRDioNusMcIeIa56W7FMpuSHKp2ijkiYusEGFxrQXDuJGwS4nogza1Lv07DOLrsbRhblNkbACpuvjH5pZG3gCOQL6WQ9CK2FR9tfYIsf2+54tMB5XeZfjnyKqy3kc9x/F7HuoFToLrthTWHjV4gR3DeF9GtOkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3536!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074250140134"
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
MIIJKQIBAAKCAgEA0AmZkEIR1+KRkFPxvwzt9uAt6odP7F4gc+ssOumdGL3DETL8
QVb46549aHe4Wd/+D661qPGsqhFwnsD6f13jlk4qXZTjGMiMlh/MHZlFU7kQJMDs
rvjOSA/qhl+htRE/vlfD4XI4JZZyyobw8kau7vp7pkOxZg5ZtTmbzF7ZyuLmWLod
CN6DA7TUES9JDEijNdMkOuoqKk2lZHblA2rmeogk0oTOsFYSCEkqW1hv7OZxnzt7
rAaV83dscb3RsHvJWJgFEpURE4L92eLxoS0QrqJG+OuWHGCn1R86YC+uDxq6uIZT
/KvMpwEypaNbA9sjUFsy8xwloFz3qBISwrRZQH5z5WnJS9Xjiw2CLeQozeGmLAy8
iVq4M34WJ3EP0xJmwl9Zim+1IZIGKM0/L2PK3xH7UOpcVNttey4zwrB8rCgWu2qC
vLjlzNnZxwSCpZkWE7JcS4/py0mEA8cTrfCJ0T+XnMkITDDif8VxclOMJTvwZm+M
EypROAR6yO24TS9O5cfsDZF3iiAT7gQRDioNusMcIeIa56W7FMpuSHKp2ijkiYus
EGFxrQXDuJGwS4nogza1Lv07DOLrsbRhblNkbACpuvjH5pZG3gCOQL6WQ9CK2FR9
tfYIsf2+54tMB5XeZfjnyKqy3kc9x/F7HuoFToLrthTWHjV4gR3DeF9GtOkCAwEA
AQKCAgBY1ZCWcjAOYLhJyh6zt0CyJ95ThH5Tb4oqFaUobvNfSkDOyle/SvU2H7cX
MfAtqKFjbvYxcymI4bOWhs8wrhXt6+jZVyd2QMUPofpWNUnOS3siRqOKv8HOMcWy
pYl2uSvgCrghP9XL7yeLZf3jZt1yPNGqGMPa0Yvq//OQXHxhz2wPPUICtIl7fq8D
u45UyXuwEz4oTi+9KrTSZpa6U96hOhuHLaDY2ZgPo7aLlQMORQUFuq+/sHw9n6RW
GXk+BE3hH+EiozbMfyYI8Yi+i3DRMYhe6LKL4ZYpQpF520JXPtG2091vSqk0MyW+
ZzgJOH0m5hqmh0Fl7ezu/vC15a8qPrkZYPeFvc3KmRgd69ghnivQd/w/LXRVwMJq
nsrj06rNS0jFfBD8PU/E3JN8PtIQiUCup63qqeKUQAI54IewM1eFbCeY+XtnfWHr
3GT7WsAokSq8Y0OiUW3ZnkztgBiWlIxR8iIp+4mXZmmzyVmXdH+h8Mhuou6JOnRM
Y3aQo3T6s6n20+/bilEC4fyHQJLnASO+fOf0zi8ve497O/JguOMILSjTTAGfldea
xaUziATtDnCqC1dxDiBoCMaaf//pcICs4LPLhDHnpcISK9sKohtMfdi7gG9mTdIv
cn0Al5Le4cpXQsFfdWpGlb9+EwuzC0MY4zXZjhEgVsCruKofhQKCAQEA8yVAKt4R
SkrMbgIoVN5A60LZOE/BC2bZEWSm5c/jpTadVfYE+X8+lmFN92+7AoRxSGWeMBX7
Y4q5wx0qWaUtwgAorMVU+86Cepbn1gsZlVwjnkVGfz+JlJYGvdWIYSTDahXA3Tl1
F7xwd4v4eXcogFl9BvXaPPjcLnz0RHbusnWeLj0paVoT/7vMc/ig8GMWzYMs6Fet
fZlZ9aG/w8bRX85mpsyx1LIWCVmhaFAscBOm3UBVNJtnyhHz1Gce5slY2RfOnoHq
A/9JFJP4n1k7YCbnrhekWl2ZB2F9ECrdeE7XoMCvVa4hsg/3GLSPocL+9u7lKM8D
KkxHLxREFV/i0wKCAQEA2wkx3VAtRy9SerOGAPX1A/M9R41UJStcVen1Z5ZNfzjA
yR2y2GOatoX/c1Tiq/RexefFznoat2yCqMkYqDS2PIX3tTt1zEqEqeAu/ii7bglw
JOQ+ocaXUe5amRYU1COrOE3QHcpR9umaUp2eV4Dgr1cAYkfU1pMmYGIVGaLPYUWR
w7OuHy476uXkX6B4TWDp1F2xKEi2wdBtdjrSN9K8bT7Heo6p5GvWLv/xhC0mCGtL
gCBnQPLiyMtXds8vaSTmaxH9BomtkktHY3MwM4kL3jpnW+8UqXIeVteCND+k5DM5
OkF9YVgIv7ftvDTbGA1q5iMuMJCuUGyYaVi55dOb0wKCAQBb4/gcO1DNgvc/nBEi
Ad0HDHyLi5ipdnUS3bc1oxullL5hflji8fP1YVDV8qP6j5NAiSb/hU88j3ElDCC1
QHfKmcTFhs5XW/Rz4BQ+EHPavre3WPcLoDeesBRcKhcgn4Q6033QHabjEZRvmbaO
MTpdR3S47LFN2b9c0lx+g3QyfcEKOJMt/Z0RSSg7q/sm3kv/31NZe8lVbl9RNZAD
rV/zlU22PCX4/FTXs8gMZEBnGwY1F9sbxp+y/pXn8BD9p5qscRLlVLPcTt6PqFyN
3GtUK1/jq4uxmy36XB2nvot0rFdRqYCaIPUbFm2MKLEfsVIqgJ6ajaHkmm9Mm5wf
d92BAoIBAQC109g1JE2x/jK18TmYqpUPBmkkcModYPVxzJoPt9H1fqNrUOAaifTw
+COrFhhlLqNOHq0yTmLHSajdfLKfT8LIU13icM3FHUcrzhK0ohOVsPgLZ/4mRblw
JjHHS3FW+ZU1VEMjt8R6+ElHs9iyQyZB6DNFYuPojJcbA9EISwNkeGAc2Zf+Al9z
DAyc5ZV4hq8VwAFEs7gjBGcZ8pJ4DNSmy6rErpGSMYLH2WgglWoxKwCuCDguznI8
xbCBzFRLMHqm/3PQbZJNE3jbsc+duHLFtC4BP2Mjlrxg0t4fiYXUekFTfvIaUP5S
SNltl2MZgGnxSdsaLcDGup97NFB93UBJAoIBAQCljl/bVEKQwMg2BKsWMOQ/3OZH
kDwQdAsXAEel7zUHLSgQF77qbyHq/tLL0MgTnJpOOLtOqQ0QzMolGTevTszBQ6cv
XjMDZZswdvWzy2F+6C2NGB3jQPtYEs9lPcnJJf0XVDz4eU6qkKD4+no5iFrq1V9y
OEWYtDeTSMReTkfocjzVhteczLddxPjpLcKKJjBQH7XsqxOUO1yCktcgMNojdprx
ww54uWHf3MuYcRQsBcMljqI6qb5HYF0/R6VJclZ5bIxGIWmoQNnBFu0vZxbgC3Y7
2rMJSlr92iVMKUFhEegvh+v2ezsp4nrIn3YrX3WOXodkY6t3X9OoDg0hG5ZZ
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
  name              = "acctest-kce-230616074250140134"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
