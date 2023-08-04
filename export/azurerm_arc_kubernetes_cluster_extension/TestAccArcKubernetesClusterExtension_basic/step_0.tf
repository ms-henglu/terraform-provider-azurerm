

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025414261666"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025414261666"
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
  name                = "acctestpip-230804025414261666"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025414261666"
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
  name                            = "acctestVM-230804025414261666"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8730!"
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
  name                         = "acctest-akcc-230804025414261666"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0cAx30W/87b7rRkpqJO3lNz13vVWq9BT6+tH/hzS9kLAFY5o9uTq1ZrmDKDCw0TggFA/ITpRd5jN0kJT41usmSQUqX/szg7krIGBo+Z1kTD/rPV5F1NpJewhaYGpfDf5j/6lzvNOzXxvxLI0VZr2iM/Sh+xLBmAcD7/9IFiSqW5yUGwDu4v5+DZNTBAljsgMvcob61lARMvrbmW4gvx7GcZL+H0bFItg5hVB9Y9mS9+k8jfIW5/d/GI/i/K9zg5uwLC0G1Y9xS19CGuE/FYVqgb0VZa6H+jPIId+IMGzEMCZ0CRW8cjnscmxpupy9mWBVSw8e0STvAfj3hlrAeAKzKSJP0Z13cMYhmvAkBYOm0FGlwdznCSQzp10ac8eVgZEYwiodJKaR/BmdBV2c1uLaMXHdVAZ7MUO635+dXmx+IfqclhykldLP3GCH68mRzcKe5uJ+5hX5+1I0bzm2YwfBr/HslWVlV86Jwe/hb/CD1K349KmV9hRQtsZ6zjg6BLJeGSunsJymvtmXQqfif289YsRfsTWoagUUT7YvK5jaTfo1crmVVZru2PYDaU/xD48vu2aZlYNJLyNO4VjyAzVv7gQcitg2TwGnD+TwhSM8KLXyO4/Z8gUUcYfs0fVNmln+mQ9m7PyuI0vjHk1zN2B7EOsF6fiZdupfHyWUOluJ78CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8730!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025414261666"
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
MIIJKgIBAAKCAgEA0cAx30W/87b7rRkpqJO3lNz13vVWq9BT6+tH/hzS9kLAFY5o
9uTq1ZrmDKDCw0TggFA/ITpRd5jN0kJT41usmSQUqX/szg7krIGBo+Z1kTD/rPV5
F1NpJewhaYGpfDf5j/6lzvNOzXxvxLI0VZr2iM/Sh+xLBmAcD7/9IFiSqW5yUGwD
u4v5+DZNTBAljsgMvcob61lARMvrbmW4gvx7GcZL+H0bFItg5hVB9Y9mS9+k8jfI
W5/d/GI/i/K9zg5uwLC0G1Y9xS19CGuE/FYVqgb0VZa6H+jPIId+IMGzEMCZ0CRW
8cjnscmxpupy9mWBVSw8e0STvAfj3hlrAeAKzKSJP0Z13cMYhmvAkBYOm0FGlwdz
nCSQzp10ac8eVgZEYwiodJKaR/BmdBV2c1uLaMXHdVAZ7MUO635+dXmx+Ifqclhy
kldLP3GCH68mRzcKe5uJ+5hX5+1I0bzm2YwfBr/HslWVlV86Jwe/hb/CD1K349Km
V9hRQtsZ6zjg6BLJeGSunsJymvtmXQqfif289YsRfsTWoagUUT7YvK5jaTfo1crm
VVZru2PYDaU/xD48vu2aZlYNJLyNO4VjyAzVv7gQcitg2TwGnD+TwhSM8KLXyO4/
Z8gUUcYfs0fVNmln+mQ9m7PyuI0vjHk1zN2B7EOsF6fiZdupfHyWUOluJ78CAwEA
AQKCAgEAue0hCCY+4Z1I+IZ+i+Ts7XL0K3/UJRbU3SJBPbp1Mj+3HySOXJRMqa3V
0EnMeuUaEAOSAjU8s8PqZj/PNpEzrMfz3M/9rCY9g8CElzGY82u4p6ssfIW+hhQL
BggeoXLIsGBsv8ajCrkMJhJFG8DyWhHGMCA/3NXi6f8oNLzuvGufvzQQFvYcTW5t
FEiX0jn4OV/nYbZKpvEPr1tRtCJ0SEOjYhAbqhlmem1Le41ygz0qbF8QJk/OqYK5
i6dPolDe0cWQ0U6gEKGi3IzaZAc2yvHBMgEa2WA4AkC4h/bLcMUZUwxzWX3aC5ma
9TeLUmhlvYcp0abXQezIiz6CwTXEu0iY4yTnhY7XUl/EniQEUEFBRbOUlJBBhLja
iNjQuk5hkMTaHh3RhYOfHDaiZZM99yPatrrJ6J12jCRrSM1HyqZ89XFDnadzQ3IO
81TpEOCBCAcqATVT/eZZ6XR+gk5MFSblguyp7QTHJVbAYMkHXjFRzg1MfIiZDFTR
xrX5BRqq2Py2I3J457HR/8Et02NhcPoj5gd9BiVJ+o4rJt0z7n8p4xH69ZBrdGX/
vShL4sutCipthTPm9Ygkh9KwJdsDaYpR5wpdUW0HX5CFLn/tTpm2vLWUZtFJp5hn
XSHgAkMQn7plPjKzGEhaZ90n6iKpebY00ZMvh+0vKGpfOdGa+vECggEBAPQ1jZw7
WDVLrMP3H83ZhI9ggyeADTPMFyJF7m2XiEMPfzvGp+9U/XlKbp1sE9wbCNSkNpk1
r9p9gblmDaPUjjHY+ZpD0VlSUF2QjS1/XgX4On6v/Sabumug3rylAa5t7z0iAKTb
waPNLkXLwkO14kLy1sYVvW6rmdg7tmDmNL7Zb+gS5EcEmYytchGuK5Gnt6wHTkCl
AQmU+wQX0kCW6HM57cl6hB4ALJN+51RFEee1PTt/Pm1sZ4DLsSD09A38P3QX8bMy
tCH5U/1n77yzueo6l5X3qaCOsV7sqA1pZsk1bODF9Ck01jR3EgbtFXoF2xYeBWCK
BSAVn5wp/1/k58kCggEBANvgu4GPdZY0UJezzU4mab3Y8z+AUCCzNXoHwKc2R3MM
fiKiDmLs3BAalwPyb01K3O9lzTZpHdskzWN2YMp9EAYEcheYSVqCdsJ2JZ8J6LIU
Ijh+qtIdHI1iGDosyw1UyDqgC6PB7rT+2xwP7LUr2cD5GgJBUW2XzSWedNSYmz35
htoCIrvawQrpS/oYSDqghOV04CmT/diyTkQSGKiHN6SET1AjbhJfVHriMZxRBiWm
j8BJzqBlgaduAb9f6vHti3f1ll/GMzFlK/xCczpWZdH1xUA28U38eNx+UTS7PwBG
ACZqQoJZm/J2wWNJ93JYiLUZYdnXjRVR+aVVu7IwZ0cCggEBANPhRv0/K/gJsVrR
JcH3MKEpToHOAyZms8ejvwtMxwfQAUc+w+PN7KH4p2JkLBLzTcUYuNpTD0FVVWEj
H0B+oeSz6VQj9RY3aczUJvlLoasyRKY4UT7XLHZHPBmWXJAXh9OVldNza12QHs6l
y+Xtf+MwSJHSuOm1bySCImmOMkNH6mUDRxYq8oJw1iBq6hhU2PIj4IwL3YuPu/5A
IMazZ/jZUOtXJhvVcNeD6ndd+fv8bqUZcHOF84N2tzbt8HXV3sP+JlGg81LqvSmG
rSUfFnYX4f9WwtCwHUpLsD76rRh0BwQ6G+5IjnU0vepOdyzIud5Fq8qn1WyR9kqK
0axEsakCggEBALh+7vb8uE7r4MAaN+geZVXOh/U9pn55wSJ/BNGJwxQvZFuNHYM2
ekTs+tBuCaSSb6ZVBodkVo/+ZnTR7M+bdumFq3JO7yYKGLp9Rn4XY3ChYkGDT7R0
hvO/XtLZqRuri0Nd7cZfwPuQaaw3VIiEnffFTWSdCEVsPdAWELQexQyQpu2hIyH7
oUWVkpHs9BZ1gG3Ezx80NakxnGiTwqsOosrh1mdJA2BZK1rdF4GxnvXSuAZCKCYA
ZnVl4gOB6XNMvl1O7fm5JlWJLgpCe8t0mYU+s195eqrUcVmaiGs1vtxs4E1bliko
Jamiqgy1EPOahENpY+jVbGV6Xn6z3IXdBZsCggEAbLiBrKphyiOhfoGZSnkMFnCJ
HuOCKW+imhrCKfOQQlvVQPmuVwBAoIslXRsoVZqd+Xc7CoSE6OEggcDmhcfME7+S
K4JQddGmTQOVT9smrNfqSVajAs6DHn8jCqLBL/qJkYqJ4bDvl07FiOQhX7zYnJQq
d7Sdv9fayBai7XC9x/xmKpNDhrhA/04Pe2cF8zty/79FlZK8DNHdJHjhQYmZFgVa
GgCcP+r4XoR0VthFc4PxdzgdQwZ0/Ko4XKUnNxs9UxoBUlv0JhRrKJZazZSEFna/
wJHS9ZhQoEFamXF/czAKrCycDt/3SdpjORtFDGqFPddLaZezy49pWz33xqiNsg==
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
  name           = "acctest-kce-230804025414261666"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
