
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064356529534"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064356529534"
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
  name                = "acctestpip-230929064356529534"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064356529534"
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
  name                            = "acctestVM-230929064356529534"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5601!"
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
  name                         = "acctest-akcc-230929064356529534"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuDlQmzC8A/0Y0xo02kdmUZtmqV0nVfvaymlek8xcez5ZvA0NUZgVG2kFAdjna1DUjEHuCqWUtR/6xOnv1ioF7Wl9ydhZvv0uHFwQAW0yy815wuR+1QwdvlPV0VapJVsM7N6FKEvsfu2opIwpVizmjjEn/RRlM97tSJ2IvxFfF8igoo/aew2qOQnHbIneccfp7YNEwAlEKh0Yx854LWHjrXZjrrilZA7T3/yvUlibmzgJ5I2FqreaE9NpNLlgY+53AHqR6SRzk80M4y7Mnow7RU7N1U84NGWmHoFwZ1AZgF0Qf/bFmqqbxKU4z+N2A264s9AZ9mp85Pp4W4cx3bFZ/FCh33MMIKF6/zTfHeyM0S7CxLrQfOmNuJlk/eyhBTpbMorw9yEzvybgI27Pjaj4+g5wefPl2SdBU8vZz1e22C4haFbLhgfPqprVTLY57ZRHgckFHlS8yKTqb3ldMARxUN7F6VfJJJx0ccUOkqS5vWE+PNmHunX1dzrbPJeHmkwoopB6AonKpWZ3gACFFPQpSbT4fYDg1pstwGa0rVWZU26XkU2NTygtPfabnVYMA9TMNwbW3UiK/FdA3S/Jb6MDSjYf3hTXC+0Hg31kTDyKPaY5pNMrSxfkj0YtDLgPIv1GjHjOPQauREiGS1PHHMjJdy2zK3tPcgmrzq6pMkUcopkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5601!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064356529534"
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
MIIJKAIBAAKCAgEAuDlQmzC8A/0Y0xo02kdmUZtmqV0nVfvaymlek8xcez5ZvA0N
UZgVG2kFAdjna1DUjEHuCqWUtR/6xOnv1ioF7Wl9ydhZvv0uHFwQAW0yy815wuR+
1QwdvlPV0VapJVsM7N6FKEvsfu2opIwpVizmjjEn/RRlM97tSJ2IvxFfF8igoo/a
ew2qOQnHbIneccfp7YNEwAlEKh0Yx854LWHjrXZjrrilZA7T3/yvUlibmzgJ5I2F
qreaE9NpNLlgY+53AHqR6SRzk80M4y7Mnow7RU7N1U84NGWmHoFwZ1AZgF0Qf/bF
mqqbxKU4z+N2A264s9AZ9mp85Pp4W4cx3bFZ/FCh33MMIKF6/zTfHeyM0S7CxLrQ
fOmNuJlk/eyhBTpbMorw9yEzvybgI27Pjaj4+g5wefPl2SdBU8vZz1e22C4haFbL
hgfPqprVTLY57ZRHgckFHlS8yKTqb3ldMARxUN7F6VfJJJx0ccUOkqS5vWE+PNmH
unX1dzrbPJeHmkwoopB6AonKpWZ3gACFFPQpSbT4fYDg1pstwGa0rVWZU26XkU2N
TygtPfabnVYMA9TMNwbW3UiK/FdA3S/Jb6MDSjYf3hTXC+0Hg31kTDyKPaY5pNMr
Sxfkj0YtDLgPIv1GjHjOPQauREiGS1PHHMjJdy2zK3tPcgmrzq6pMkUcopkCAwEA
AQKCAgAmNPzassjLqvozDgRYIOa/lhM8nO1Dj/BYenH7BS9JAC1sKujQO1JlVOqM
74dPYnwyepn760tkJTXFER+Es0J3cqF78zrpuWiOySkoopUeX4cZPHpxhQnGJ2z4
9Zgu/ys3FQ9YxCZQTMnlFoycKsPGSbuZaVlz4JAlt0ZdGiU2sY1fKaaOTs829Sg/
Anj38BY8BDWF/mX8tfwltFSIVPz7RMp3uiPTFKAsnCNgWLAtCPpERHWsaleyNO5k
2O18zEAyATmxuLWfua8qjtIxL7Q7M5TM4JkvhMVnHkFJq/sd/C8n2u4wnaGgrwOR
WgNnwtbbtBUuXfd5JdlAYlGdQOMAbz8h8+ZJm+mnxhQCVUvlFdmdoswuodW8czNk
u3rg0tNIAuDIC180BAES2bqu9rRb/TZHP9bnBstcA+26IQPyObSbv5EI1wZ20KOU
j8TbQ7MMRQEfX7XgzmhiKND1OZF/WgTYbJ47xEyfVl2JWEHdFwkgWfVc8/7deBRo
jyUqdtXTKNrfnZBB8GIesLOKIqud7ufzi+yJ3sFoKN1VH4Ius+IjJuCEIEQWqPeq
GM3GIwZsDact3QT+NI7loAEzig+6z9SvF3NuILBengQpZ3UAXyhi7LD3QO/Q4Wnq
+Wr0BH+bKbbspv2/kAGjK8GBD/V0JGnKAabeXX0pQ9KRSeVM4QKCAQEA1KIyidtD
OKGR3OQ5HjoO7bIJyJMpQOS5QUjQKwh+YCEUVSe6zoJJSDUpg2Jv6STTSQlUAhX1
ap7Zri9jtfU/dVt3aTjZ6Ya2X4u4PhQctelQPfn2j2dBICCNniEccyjFPom5VGbF
j2eune8qTlhq3LKaVafCE5L9ixOxnWEshD6NQbd/wB5gutpDOCPixhRzaNGa8nDR
0egnxGHsIWZo4zdbJtGGGPL4zIzOBcU8Rfi6k3nHEGxcr7NBZSevQm/RyyeGPhYy
37AieUXLtqbeNf6qs9Qk7vKlsueVDfrlas8BLrd182CTPTat3ncgjx5Bzu/zxLtG
ZueMCW8flpUslwKCAQEA3cvR65jg+//HwTtgL4sRLQy/O5W/R4q+YoJ9Vbfv6t/1
tnL+UQzIOslIq7yChqjbQJ0oPXyWLoBfAeiJMC6gJi/DpXWVhAFFw8FruTaicx4o
DKy/ycFnfpakNPq4NbInDudPeiSWJqhX0IrYe4lzzOdomNytBTHHdK3D3bcMXkjS
SAQyeAIp1nsNHZ7ri9hA7d42aRFvZ0UqJShz0MPmqcv2sn4aG+FkG8ZtXWNHA/eD
6GDwK2iyKJZOg9X4N4fGxzGe4WdkMzCEdJ9XeIIJ7SCRwiYa0sZ7tWwb1t5/Rw9u
yV8iH50gIqSwCmT9QKC8CkWVN/5ltwqmX/51l6cgTwKCAQEAhlj1FaU0E9QCFU8d
x7tnM0gKZnCU4Cuj4VvgK1ByiMpdznAL1+753mW4lQrdKrHZzYvXSHoXVgaIA0Zt
+cm7Dqt8Bz+kb6huEnB1OMP8X/PKf14wKutSeroWwJKrJxfbiGf8cRd+O92GtsMm
N9olqswuN3CHb1awW+9VidqcBfJ/zcXjMb//3g+J6S7DWeQSB2hoPkaKS9YjSjGU
wIW0P9v5+8zmrVzXVmagxYSZUJyXRhbrb7UH2vunlgI8+f0s0O9oIlJkUnE3VuiC
jiVgwTznHjgsHc2yZBduVibwTUv9s0a3f87FOSgTMzyRldvIOLfjjanGEb66/Dr5
+mrGgQKCAQAz5CzP5yu0Kaqtjdu6I9o35QSUxztCXLagS5FRTcCG/jD5p7vScKAk
CNXEwEz1fmoVmu9AO3bTmFsiEiqOqEn1xTUL8A+0G6wb2ZP/eEXXkxWhqYURiftR
xaLTdllEztKOjRWuKQMsNjSdaO6vMIB0TyvMn8ynK3dT2Be8NshhAr6X9MtuAmuR
b6ao6HaJeGXwgQ3P1TFwQuFSYj1+eWbtEPg92Hz5SulmCi2qLMD/r5gf9RYbwdn0
3v2toJD7RPv/vJ9EczEhPNewhVssqZfy76zKdKnP6Hom/w0gX1v93yF3YZeVN+i9
0jQRqoEJ7tEvwgngWNepVIeKa/lNKt/HAoIBAEf6HXthGhBYmRbj1GZ63YZTbyc7
rq2AmdMGyB2eeOdSxrNHMWqbPZqkCiqZFB/z9Mt7Re/R9rdgERGvi/NSWQ5HL6Fz
rfvwnqT3UqUHxjFAxlZ8U2EEwCLMylbfgVHuSCxATr4L2D49twEhsJ0O3XBIDmsD
jaO6f3nXYAakr4aqrj5B4N2tA6bCn2PCM890k5xAe34phTpsKbwxGAW8V+UeM/Xk
5BeMt29FXeXMLgOUgD+SANpdiOxtolP41Kicsvg6P0MxQAmJC7ZcVL3a1w182WDm
52R7NFM2wVMV4t8rqaowiY3R1C35y/LA3iDIp+2+P1ra3wu+qoU2AY2jiWU=
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
  name           = "acctest-kce-230929064356529534"
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
  name       = "acctest-fc-230929064356529534"
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
