
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122318860954"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122318860954"
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
  name                = "acctestpip-240315122318860954"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122318860954"
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
  name                            = "acctestVM-240315122318860954"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd104!"
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
  name                         = "acctest-akcc-240315122318860954"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAw19curn1ihck1MQmIm0ZoF9pZ/8mM9bYz3dSYULfD8NLysX0HxnE8ROhMrQ0+lDOaxhvWJ/bVjaOsEBZ6OT9CkjrSr+c6WE5C+KNqfVXsjwZhtC9+3T+VfpJETzQQELXyh+tOov81t+VvGwImZthJ1PPkNEk6xX8eZLnskhlbaUFQ9DEqww0zuvow74xoItjxqszeSBGSbtd/cxLf4lEjYAdLFA9w5miYrcz7BEYq+ApU/2tkIGzLnX9dOceV5Pr+Ed1C03C+lNq2IZw5ViDyiBZj1OAULOiojHs7QSfWNh3iijFcwAAI2uRlwqsP+79KJoe9Vmsg2HjrtJcpYATWatpF9appBTk89j4yjZESi5Nr7bCXcsHULi2bnLRQDxD8vz6X/i8OLIAJ40KM3Om5v9ibfh89Ad5ybMlwWGBYKUMff2ckD5n/iqVryqqXqQzH5X+F0Zj+kam1gQVReXbiMCtC/77bPYW9Re06Kl2RfJEXPBipZXDDwtCq293RUVdsyp/43QiHpRflZpMgrgASvrUikq3/h0+eOTWy10urs5aIcmGr2oeiz78rmEFGgcBtH/0K54KiZGyEQb8xhz+snkkIYGkk76TNHg+6T4cVhqcO32eBj6fSy7PQbP/me9z1pIbDY9q4Y1qn/9KDDi2s351cZH+z9BNJuvQVJinRjcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd104!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122318860954"
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
MIIJKAIBAAKCAgEAw19curn1ihck1MQmIm0ZoF9pZ/8mM9bYz3dSYULfD8NLysX0
HxnE8ROhMrQ0+lDOaxhvWJ/bVjaOsEBZ6OT9CkjrSr+c6WE5C+KNqfVXsjwZhtC9
+3T+VfpJETzQQELXyh+tOov81t+VvGwImZthJ1PPkNEk6xX8eZLnskhlbaUFQ9DE
qww0zuvow74xoItjxqszeSBGSbtd/cxLf4lEjYAdLFA9w5miYrcz7BEYq+ApU/2t
kIGzLnX9dOceV5Pr+Ed1C03C+lNq2IZw5ViDyiBZj1OAULOiojHs7QSfWNh3iijF
cwAAI2uRlwqsP+79KJoe9Vmsg2HjrtJcpYATWatpF9appBTk89j4yjZESi5Nr7bC
XcsHULi2bnLRQDxD8vz6X/i8OLIAJ40KM3Om5v9ibfh89Ad5ybMlwWGBYKUMff2c
kD5n/iqVryqqXqQzH5X+F0Zj+kam1gQVReXbiMCtC/77bPYW9Re06Kl2RfJEXPBi
pZXDDwtCq293RUVdsyp/43QiHpRflZpMgrgASvrUikq3/h0+eOTWy10urs5aIcmG
r2oeiz78rmEFGgcBtH/0K54KiZGyEQb8xhz+snkkIYGkk76TNHg+6T4cVhqcO32e
Bj6fSy7PQbP/me9z1pIbDY9q4Y1qn/9KDDi2s351cZH+z9BNJuvQVJinRjcCAwEA
AQKCAgBjgNQXfdJiTDtD6cqKSgp9NVrXzolEaa3urBTW2FoHCy40zfDxTgyRw6+b
xVAeFL2sqbs75d6t4Ad4GK4yAT4m2NCNN13RNuT4+p+v6faKHjXaBcJcqU9Htrsz
/kcKE4EXvl5ZrSZOwXzfhB41LX+jqfnTBdHJsV7vBDThBiIyX5N44IDppMPYhyn7
V4iq/ZMJgfQrQpbJwpWyRzREdkLl1lQFV7C9SCf+ItRc7LAmCXrC/jZBnO0HQqyd
t4Aqlnnd73bbFPWyzH1kXcRt6lDkxukWKC736yVvegHzDSGi/EyVnwJA+cUYRRbX
WGY2AaAJ58TQrKVCHL77MMRivgIcC0caKyzf2xNBS8tDA32/4OIp0BrZYK2zbsZ5
5R2cqeatjt2WDX24AkmHREYagGhGOKeCfOgn5Ms0wfoefx+1O+sRS9b7XtKnl5G/
Q2YIAOTkkAzysuFDAcV3VaD1P+OPEZ8a2ioZwRrunGiUcd2CJ++iP4NAXYougVKE
Q9oECM7pt7ar5aDFcBZzMerdO814BAcx8ktUKQf1I+di0nzhAYTawca55T2WsYaR
v3z8YP6Nq022/JBYXoHZHCFu2WyD/0Iq93LNZ9pwNePbrTVsnSWzEeeVMNkjQUL+
oHTNaWQceW8rm/Z3ZswFgC/LdFVsYFcWJ1BzzCSD88lAwG45wQKCAQEA6LGNzxO6
49I9OrhWQjWk7XnzMTFgHV2E+XebWMEm1mKYH/RkfrBMRy2XSDBMvEKj0vIyhkcs
xT+dptcmyXJu6izeFRwWVNQwnl37l+sFbw1iy9wxLujcZg3bMmPLzK3999drCZQS
R/SHCYC6rYpi283l+NIzTF9cX9Jny7w25JbbWSYVv5PB5FLhjL1YoqyhfuKGq880
2RMf4MR21wkreWRfsXsNoHMS09NIOBiFcdw/BUqux5kpjvRZR0IZRh+i+oowlCM0
ATDg979oSU3a3fF3VIH5vz5Nbn25zJ00EBjNnbg9rXRvwmJRgHsQu3ri7scm+jNx
Xum7k4Vu771phwKCAQEA1vDd7ywrD0WTe5h+wwq1RzFRKK5S7FzWSBbcN3ETrhp7
sXszByfoD5JbJmRRhWENN7cHw6xE+Tfnv28yUn4PedzWwU60rege5B4fzLCgj0KA
yi6j32Z0kWV6DSl8bGdNmgw/tk4m8kRc6ToEdO9G4/OaPS2xKDDRD5jmzWvQPzjb
avERnFhnseA5dRHBbrg+gr8t7kvn/QoXKiu2HVGt3Xd/QVAAndF7ZrgLz2HWDS+I
JfpLKpmmNnq3z3qIjhM/8DBL8ItaeSu3nrdbpH8CU7w0nfnNgrCOXlQER8BKrJXw
gc2U+HMg3ipH/WUgq8g5/bb8LLSBLqTfO2ob11ap0QKCAQA6IxJhKHbLMN3na+Lx
S+HXC179bW6sJ49vnLiNZkTDz4JeiXsKRBXqurNPb/HcH3I65BRHhETlS02iP6ML
NbIMhAVAlPHnY9R53NVdUXTcGCYU9QC8zaUzQkb/wftLOjV31LSDgiFHJQsQDr+V
WDv22uyYTDxQ2oqDzlfsiSvV1PMcxO0uHkaVOzfrJ+ubSTJYN1SaXHzBt4uBZtSi
SUI5ZCCcgTgYXGfZ0LH8gfPlTLfaJJyiddvyQY6ExTj3UjQwEJKukFUP7xxmCcaO
egsy5H+B969kXraN4o+nVaeKVggZXczbJ3o8wL/IL/cwQDWunsdYP74VjqQ06WOc
NmDFAoIBAQDR5Lj1HE6YRTs2UL5IvKY1dWVpsoHrquTd1OULhvLO67GqqUI1VLT6
r9Mu9HvfId0EcUm1vP5F2GAIww+DGvMF77APaUprIOc5oGkxO7Iu86RMy6rfN2/R
pCTBwadtPJu9OQTmg/7oSfXpEuzTO+4gH/yYjYwYUUN2VbvdEdF0S5OJJQwrfvET
9IBnYAVil60DhKnXsGxE35urZLAchWyhflXYc8WGV9CHiGaQB1w92BK982N/oDd9
r+zbQS8kfovLg35E0fBxr01KQofNZPHiz0Eam5wiaUM9vhHH93F0g58vQpCc5eBM
00Elo6F53rcymYQ8K7CS2hHcNUwmxsxhAoIBAA9oz+e869+ZGb+IzEFyewiHoIjk
8nq2Ae/t/dN1/3rThHNjZJIG7cHdwoJpdq3s4wr+AKZKaU9qLKRcO/AviJIyHko8
tzAHqYIeBc6HA5L/36lnN32V/U4GwHHc0FPJPU30btuFEuIDAkDHtsWwn3lTz+q7
eGDvGTctPlLj0MsB3SCx7VOV9jF7hMv/SUAczXipAjc2rh+Xq+uNXeNAIYotTN4D
HZ1+c9vMQxdA/QPlK3i0HEVneQR0lD1Xd1YykmRRJIxWre5Gtp2TWPXe4GIkk+ps
FbYgBtgN0uFgRD4J+CXBBlc0jKxFZpV/M/EU63Vpwy4QxN408XRJFoA0mCo=
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
  name           = "acctest-kce-240315122318860954"
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
  name       = "acctest-fc-240315122318860954"
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
