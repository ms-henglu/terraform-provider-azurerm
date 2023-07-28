
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031759250229"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031759250229"
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
  name                = "acctestpip-230728031759250229"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031759250229"
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
  name                            = "acctestVM-230728031759250229"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7834!"
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
  name                         = "acctest-akcc-230728031759250229"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAulgHq6zBWLJR+mFLrReFxvsXICNpKLTE2tEjBnPhX3CU3YhAGZ82sAR9dL9TYO+wafR1rWZCGssRNP6sUJiIwqeUezOz80ZNPHbqtp5uymovm5INpPgMG4cLWFmeG2/XrFqJv0uqMj0erdyryCvblvFpmzKIS0ht2oGYjS7vJ0UQJDGbJ+t5/6CrinRkhubvpYPR7nuAVA2k7iHvpvfchKLQBho7hjTqCp2xYt77olL9W2d7AlHYxWBDk5uzzFRCpy1H4gccNMD8FaBpitCG7FyJDAUF7Gk+h7YaSNQC7YtIqQdIrUvZA/BuMbA30aonWKciZPiLNcVqSg0XS1muSPwgEzorO8GFQ0seapMEI1QgAUwrDfZ3uVqjv9AMNr8QwXD0K57eoCfIvuH3eC5kkTcrgQbUoXbYGpLSFIdcGm6zD+14H0s0bJZvuxv+Miqx+SEaXqzmoB7BDV3ypanfDUBlcX2UyHpB+Crkf3+MEK2gJtdA7y2htP278/61sQdVUKftubc8oPoWJOtIE+07QXudU7j/FrtCcGszfJ5pfCCSwolQGIJJdD4RAH0UY9uDo4ZRYeiUZE2i6FFU5o1Eb6FO9WtK8bat1RFsui/dKR0jYddQkS7KF6eI2xJUYo+8i+xVLUEo5/0WhlQrIc0mussUNz5NdtT6JwP82Xvw2U0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7834!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031759250229"
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
MIIJKQIBAAKCAgEAulgHq6zBWLJR+mFLrReFxvsXICNpKLTE2tEjBnPhX3CU3YhA
GZ82sAR9dL9TYO+wafR1rWZCGssRNP6sUJiIwqeUezOz80ZNPHbqtp5uymovm5IN
pPgMG4cLWFmeG2/XrFqJv0uqMj0erdyryCvblvFpmzKIS0ht2oGYjS7vJ0UQJDGb
J+t5/6CrinRkhubvpYPR7nuAVA2k7iHvpvfchKLQBho7hjTqCp2xYt77olL9W2d7
AlHYxWBDk5uzzFRCpy1H4gccNMD8FaBpitCG7FyJDAUF7Gk+h7YaSNQC7YtIqQdI
rUvZA/BuMbA30aonWKciZPiLNcVqSg0XS1muSPwgEzorO8GFQ0seapMEI1QgAUwr
DfZ3uVqjv9AMNr8QwXD0K57eoCfIvuH3eC5kkTcrgQbUoXbYGpLSFIdcGm6zD+14
H0s0bJZvuxv+Miqx+SEaXqzmoB7BDV3ypanfDUBlcX2UyHpB+Crkf3+MEK2gJtdA
7y2htP278/61sQdVUKftubc8oPoWJOtIE+07QXudU7j/FrtCcGszfJ5pfCCSwolQ
GIJJdD4RAH0UY9uDo4ZRYeiUZE2i6FFU5o1Eb6FO9WtK8bat1RFsui/dKR0jYddQ
kS7KF6eI2xJUYo+8i+xVLUEo5/0WhlQrIc0mussUNz5NdtT6JwP82Xvw2U0CAwEA
AQKCAgEAjzuxEbWlnI7c0o9NAwyMqMlCGlL9tutUUTnmKUSTXLAFzU64rrkh6SRa
Zo3WAjHbMWZVueZbM4sZe9myC/VjUfRL/nNcg8drAOoLOjoHwRDj7TnTwRVlARfJ
kay5Ci/q4LFrJh58AUfXuB5h8Gg9zwVbfo7WEr/mqMlqwELuUwoUAS4cLBAlY2dV
1APpbYQ/esMbb6uAlZszRlPRiU8GMvGO4tHxJRSxPV2/BteNJlWSJ1sgQ0U0UWrQ
JrrM9mdiIGx+z29Vr/sTCXCXD7t/qljqgtGtnu26wcgo5ggJBBxGyp4tr/8YHZ4G
pazlCwU2Xz+BAYnGP5uyOp9bY3DYtDLPEhXkqhOV5QOARLA6AjxqeXOWIRhqhmEM
1jv5saPcRRx99UHredakDnPkr9cFe5G1ZlrjDAMRFeCAMn0/p1NL6jrwe14L2c3A
6tYg+/5zQ5ZMjnMQrXGK0wvmIscQt+vL+Kw+fQhelYEV36MlDmyN1kyqGvPObco+
dNnthVx5OdM5BLrhAjks7i74VdyOkEdnY6OE0NwT++rDZKYY9GEfSEtsVc1ejW02
7Y2hFveEUnQ+87GT+hzq8Yh+6T1GMroXAIDnXo5OPSIZGkTL/ClZAC0GXdzJ5WEv
xgAWZRhWyi7AMR6TfVmM9U/6pQC6wqZsJuZ4i5kcBC2Qi4Si+KUCggEBAOZ2ujEP
Uy2BVJUU7iuXHG/K4VSczDrdKpX6cmHFK9mOV0rtK7ReLgwDE8HOhCi1g4ip5X2J
IQA/BDAW0asVDki7f20PKZoAW248vvgu0tFgqSHnvC5qulOb8sKZd2MJQO5W9c/5
L+nhObpzlULxovKPEinq41AV0hWn2gRdm50gtZEmiKYBvqBHZY/XEn6VsMXDNePJ
O4TlplSxz1ZqJLWiPzaIg3aMbRfmMmE/+snUm7TGErXfV+vp1BU9cKMAJpgiK3M0
mh64DhNUgCVD2T7u/99IQoXngSokE6vDRGVMEOMyAHk7UctAbJ7PAvSzHtuLLeY3
ni0g9FXsTs4E8gsCggEBAM79zyyjQ8Ldi8J54EAZRR9eyUUNLv4+k5u7EToECObP
lAERAdZssEeZTuZaUevz2/MJIYdoUlrQmOAXUINia7Ah0+x5AbvMSmQoG0/bDM02
u+m1+jRK+hBmRrBCZ8hErL6BKzH63VplHW53pl+FvhJ+gTK+ZQhas2m0vUmVgxOw
QG0Eu8m+lKsNCheHkKAD3Zbb+e4HKsZfrQqINHt5TzR71foFcqxpG1CwzOV5xuxg
SXAjOkINFVypPyYmoFUpd9qSAxMg7jO3QK01y93bTjmPlF2lpzdCrOAG92JwOMvU
mzoIjTSymgQbovXYF9skIGJKVaU7Lr1OXU3I3H3ikQcCggEAbRDNBsCw5X0qMS9p
k3l8/K7vumJGCKl4KOgQT5LHMLs7NntNTpuvgQHHzNVWGAnmyLtWnvVRh9NKwRNb
gHKDgwowwMUHNBltK5tV6RAHtwzenewUU4cwzLalyVBlfpn3f5Pp2tWbxjxPXJys
i7TdH5tzxiCiGNlqxdLcy2odZdv/8URiMOXsd9+yAcOPvhZLRRwgGb+3CirAb56C
d+vdmZPCBKXQST8ltcS8HOfxYKjcU03VtvqOmlfbhX3BG3LL0P2CwI+pTFZgWueH
iZs1aaIjt2B0Evi/WNkf8g6EBMhdyZd1P+pByEWh4fon9PP763xPaX7yvXq2Bx/B
H6CZhwKCAQEAhxMr8hYsrupCPMupokqbR+hj8XKz+ue9DYAassBVSsGk9LkzeMj+
lAqgaUQBd7dwDf4kaieSrn63dGzidopwecTpdcRVdEbROODPSeJJTVVtdQry1tMi
sjb75CPBc/gUvlCubnQlpMqdVSwxXt549bql9wY2CiieMdnnODCgE+YNdNcE8Jc0
jxb4QfiOUU2UedDdHQ6CRGfFFT1i+jxkinxRW1HYzlfcomBtpUY9oJ0I72udpeLB
0PEFK5FDSa/A7dogtYfkyczJIP8dJY7qUje2+xGRuEcDZ0JEh3FyLtlz3oAcHYp7
ZTjftAyrLK87jsixcRzY2GJeEteDw4ZpWwKCAQBWMZO1kcpWz1LCC6nGqCTkynBL
MGQ8MqIFmh7s3gexkLnG9CgrlyJoUelIvsUfi7fdSo8SSSC8D6Ab0rXgRn9trgUp
eEIWyn0hS3mfwLBQ/j4+4wL5BzWqMWU/5o1QQ83K+Q9oaNuySww0akrTrdy490YU
Z6K3uRmf3JiqzHdrROmexHJxX4gCHVQACN75aJUO1kPBVcCsdasjy8kSg3XMIEmA
UWmG1CpOxVzEOEm8z94K6IWbNH5C5XrHfzazozULnKcBbjGWBKUsbSouiIShfOOJ
cA0FRaA8WrfT9szg5WoDw2vHomEyPHIR7s3rZMdt5/MAgYjuKW7kPe79wEX/
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
  name           = "acctest-kce-230728031759250229"
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
  name       = "acctest-fc-230728031759250229"
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
