
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032654830385"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032654830385"
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
  name                = "acctestpip-230630032654830385"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032654830385"
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
  name                            = "acctestVM-230630032654830385"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5089!"
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
  name                         = "acctest-akcc-230630032654830385"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvFeLBU1fW7TWjHCfFGDzDmWFwwHkgp96H12TzLVB8R0jBIjNnz8hr9Vk+ASqcvbZlWm14xorra4goSGtoeVcQqrQQNX/dWgcHVvbl+V64DuiMzBKh2YHoWO1k+dLVM6cTxIFyNrUN4JiDZGeAhN1BBhsCBNu2ebU4ckiMLBofnktPiSPog1gbD91GCMqj60SjhFnQcn7dHbOT698r9CYDVFNrJtSXBfBj/efzcanLnh+oY5a0TrGqm+aXDwyDdj9qvtB5RbWzIADX6Ks2KPwGsdfaiHyYKHknFhhNeY7AMnjWvSaA+EHN2K/a/5iF2iwUH/IMZIKw5nfQ4Ok7aZtiEgJIwu9IEg7xPDtZlBczQtsyJI2jNHoEDb/q3jCH1om82MIJuY3ACTihxeoNySKcVXXTNx8eLl2tkR8tAUKW+vgDXjiFf4DAJDTVVWDmVjUNVpmwShssyMzaIvJrWqoSUZClKI1Vis1pgPS3+RHwfsl/LWHJbIenO7P6IE/IrCBBRYKTVV0hWAYdeFtDVtwu4G7ai4r4x+cGodSt9/N2E5CxaIOvpZ4yRIAMADGhHzCA2/krzZlYhjnHdwFHozPUv/zG0jxhuy9WX8WGLa7+75ueF5/eyz0NcllpFjKu02jLvoGPPJSJ1TnUYCCmO/HmxWgrvX80JlsbhyWJLDaCIcCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5089!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032654830385"
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
MIIJKQIBAAKCAgEAvFeLBU1fW7TWjHCfFGDzDmWFwwHkgp96H12TzLVB8R0jBIjN
nz8hr9Vk+ASqcvbZlWm14xorra4goSGtoeVcQqrQQNX/dWgcHVvbl+V64DuiMzBK
h2YHoWO1k+dLVM6cTxIFyNrUN4JiDZGeAhN1BBhsCBNu2ebU4ckiMLBofnktPiSP
og1gbD91GCMqj60SjhFnQcn7dHbOT698r9CYDVFNrJtSXBfBj/efzcanLnh+oY5a
0TrGqm+aXDwyDdj9qvtB5RbWzIADX6Ks2KPwGsdfaiHyYKHknFhhNeY7AMnjWvSa
A+EHN2K/a/5iF2iwUH/IMZIKw5nfQ4Ok7aZtiEgJIwu9IEg7xPDtZlBczQtsyJI2
jNHoEDb/q3jCH1om82MIJuY3ACTihxeoNySKcVXXTNx8eLl2tkR8tAUKW+vgDXji
Ff4DAJDTVVWDmVjUNVpmwShssyMzaIvJrWqoSUZClKI1Vis1pgPS3+RHwfsl/LWH
JbIenO7P6IE/IrCBBRYKTVV0hWAYdeFtDVtwu4G7ai4r4x+cGodSt9/N2E5CxaIO
vpZ4yRIAMADGhHzCA2/krzZlYhjnHdwFHozPUv/zG0jxhuy9WX8WGLa7+75ueF5/
eyz0NcllpFjKu02jLvoGPPJSJ1TnUYCCmO/HmxWgrvX80JlsbhyWJLDaCIcCAwEA
AQKCAgBCujVb3IzDXe+BdEk4HB0g5aEddOczzDKlOC8sIK/LMAp/CcTn/aL+u/j4
0hZdgs2V3Qz+9/+vmfiffeIZcLxeNkxwHCFUxFzpnejQCRKerSILRrmw/NoJON1V
GGYdFtJURUtdXQJA5GW+7u9vRtt3ZvunZNMqSljz4aHGZEmxPVdlI+jrfhfCYj0n
HxZuLuBbCxltOpVnLsxreP4RADNOzJZbZ/AnBpeiXRX1/sKueSxMKrZMWKmYKtAi
i4UkWNOOp1QySQQzEcugL29Tlcl0g1xvqrVHvTPUnI9cXERdRCnTyMNkSm6XFdpB
9a9lIccNzifsQBSmNjbeoZ5mQEefnAp7yGe5rl99oJvGWSgMPL9MuK5pQBEtNf7t
MR2+lm/IG4ion5F/vAxTMSZuiaKc1yvLSh2+n9idBt33ac5XH4sJAmfbEhDP8pNf
h3qAX96rW58Qmsm9w8aGf/uP2CKtJVizh0hwtP/sc7v2u5ROlO/A2VfeiH8H6lQz
ieWgDgtv3BtYL2vWtfPvhH1FB4pwAhXGHTio8+y5BG2RFY88OBHaATS3DdgpvALs
yLOnfS4VPpRjS5tAfxrOpFQDD1lRRGJvQNyrk/HILVNMQZFHifH9TO1Me+SoKZJ/
I/M1ywI1S7urzGPOoaCjdU5hsMEGN7MJRBs1geJkulEIhYDOoQKCAQEAzSiZUzYx
lSsXBAYBDBZZSbgroVA2MAHVvhi77nxFWAi55vomFjIOyhGjxp7+yaFmJHuRfM15
m3PMqQ84WQDO+YC0D3SZS0OqiSwHgGm51eLBLA/PIECLUzXZ/UmNbUVIkvXzEm7v
tWZvnNDStsDne/fnz1UkBNdQhimu7oXJw8SlQx5zEUYhbOKe/wsofUpOeW8FO8ar
1Jl2jZiZ4ckiF1CJGEBNnL0CAslwtcK/FnAyePWYKxtHFpgWnm43d9Z6SE3dUtll
uiNT/nB54VkERYgIoUs59Auc6Y1pP/I6xcXqa2/mVlZqJQVGgsl8MbaBTxSRp98e
nV1Q6xZNGuOHVwKCAQEA6wQWAokMYQA1FdkVw05dNj0Xi1TyTnnd//kxGNUp6GFu
AaFx4EfPDz8x6Wl0KAxaXnTalnrODvhUWawEMRK5etgBd8ubLGdPBkLDAzhfAXiG
LrASnR9e9MHUNbkNIOqAoON17x+bdzmJeM89tLWcVSW0ZHCcRZEe0IekSZRQOrPR
0jPQARR9fL7nE3WDe2andiiPNRzl6zERwRgGvPnJufBZrY3UTDOVtSPArOICUTBC
2aeGcgHxWdYgPqx8eQvCaoloIWGLFyIeTC6/pZMGhQARZSuYYy255KIqShIL95t2
7AGcMLXFcLh/gjqP6a/HgbZuOCi5l1TjK2p81FG6UQKCAQEAiWW+QbdSv5cLI/ut
ad3x0GhSeAeTMtWXw2cnPZHmkw3NCv7O0SCXPQdRSu0isACyuo4zIoUuA0krcLGr
yBe9heWHMa6iF4DqzlE5eOvVtIPXYV35Fp2DcafoJTTETcEP2LR1JQw8550B9OD5
rcFFhoXBrt5TcBaPbDqwWDgrpzukfm3/HDt+mUCwwRhE9pv0MGmE9MKaQ5i/iBcC
P++HMFwUZLR0BhujJCCqpmAVv75GXzIDxiLPmjcjNtmTtmNio9fZ+Ol1spKEZywG
xD/sl3CCbxtFZcb9QIEfUt80M03YMDnR5lKbZc3BqkesMFMNCNw6rFXGWBet4LOf
0fk9owKCAQEAwct6wth0RsC/BacfVRAXuRQjiBeiP6gqsluwasPMbP16kwmoN8O/
MNlxtQHqcOPO2TkOzyuxI5MPK2q3gifony3j9/8DlFgUSBthaBRh83qJW5KBpuMp
kDcNYMeZ1dzJ+OHYbDjqICRoAiESxyNDKMuQt4pMsuj6OgbAKJSOm/mQOf/TtDBL
UkSxk9BBfc6mpL7JaIjN52VtOIcxdz+bYyKZMI5V1AhtmRNEXMt6Eaz0UzrbmMOV
W/lAWa4ubjqONP/dyDkBUzAlP7kE++oDZEUsEvsiDBa2xZwbtzyudZ3TMMYbH+ek
SlE5hA/6gD8dCw9+T/z1HZ84PKLxELvcIQKCAQA8sjzBZtXXw78oGSRvme6loS42
LT/iUd6PPX4U92qbFhyv7DnGTK7fdQuCa6dy/y55hDCnr4wWrz9NQcOb7oD8Z9W2
L/9H2SHF/LrxVPyBycwuPF+kjSDW43Yb4/rONIooLvsYQwI7UyazGVUAV7rQ8oYM
OB51qGf4SZm4cfuNZzsy5sytpGk0ob7S8OVFv0GwYQYMlwwH7FFNqAVFLKwp23P7
qu6ARqJtAab6VtfqomG2vsQ8G/OAEnLiI85CasP1pt4b/+4C3A/zaykaq5W0nwYO
kSSEAz0MOvQpk0MD3Tp/Fw4yWFqpaEL+/TVyeqRuDy96pZj3HHjjZDp7c9eF
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
