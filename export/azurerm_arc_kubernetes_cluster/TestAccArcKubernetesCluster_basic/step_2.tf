
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032648861787"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032648861787"
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
  name                = "acctestpip-230630032648861787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032648861787"
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
  name                            = "acctestVM-230630032648861787"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2066!"
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
  name                         = "acctest-akcc-230630032648861787"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzmWfzMN50okXUBYr33+YjqMZfXSekTGsdlp6HXrOx7pBlKULthHWRVC/E51nQxnxFIYdtms+bbxvB057rndsfec+6oqzxk/v68GNp+tZE6v4fcDo1TVs6W35zkScNgfrdnsH2muhTAGQnwjBbB0hFNM9pstxT54kizQwbAc2qKTYmmlxBZz89ZDEP4leKIbER6dVaTnF1Q90m0152ackavr8CSM7c+jkYJk/ls0amE2pLKGNHh3tqhWcS/EueqRizt62pGfnZ/ra7TiQkgbuCsUNrpHnchryeHxPcCPmFfaVJHPpalv4KjKv7+Zc1hS/sKbvgtJxQz8PKIEq/QXohKPKlXf4TiiWcMQ8Q5yoT7Drv8apMSpTs3b2/hhGIDhrSEMszZXSd9UQyaMMaAmP7UAFJMCvQ5+wqKgdyXsnDc0P3I8jItWtTUvzJJugBE8+M/fFNHukBpoks+Vfaigv97A0a/ljacsh7DF+YuNoOIiKYypM6xKva147L3d2Ej9q+vl6l3kh/adtWP0lcI7g+sqJxUGWPnee7+IeQG4cPPiZWLCxDD0qsJM2dl7jQetvgXryEeEy8pdhqzPAQJiD0jOq4LzpYzT6re0pZBn4g7zZESXxCGSB1VkO4w3HjKYabyT/jd9SjL96jFaVGzHHA7yjcy5v/x130aiB9T+lC6kCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2066!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032648861787"
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
MIIJKwIBAAKCAgEAzmWfzMN50okXUBYr33+YjqMZfXSekTGsdlp6HXrOx7pBlKUL
thHWRVC/E51nQxnxFIYdtms+bbxvB057rndsfec+6oqzxk/v68GNp+tZE6v4fcDo
1TVs6W35zkScNgfrdnsH2muhTAGQnwjBbB0hFNM9pstxT54kizQwbAc2qKTYmmlx
BZz89ZDEP4leKIbER6dVaTnF1Q90m0152ackavr8CSM7c+jkYJk/ls0amE2pLKGN
Hh3tqhWcS/EueqRizt62pGfnZ/ra7TiQkgbuCsUNrpHnchryeHxPcCPmFfaVJHPp
alv4KjKv7+Zc1hS/sKbvgtJxQz8PKIEq/QXohKPKlXf4TiiWcMQ8Q5yoT7Drv8ap
MSpTs3b2/hhGIDhrSEMszZXSd9UQyaMMaAmP7UAFJMCvQ5+wqKgdyXsnDc0P3I8j
ItWtTUvzJJugBE8+M/fFNHukBpoks+Vfaigv97A0a/ljacsh7DF+YuNoOIiKYypM
6xKva147L3d2Ej9q+vl6l3kh/adtWP0lcI7g+sqJxUGWPnee7+IeQG4cPPiZWLCx
DD0qsJM2dl7jQetvgXryEeEy8pdhqzPAQJiD0jOq4LzpYzT6re0pZBn4g7zZESXx
CGSB1VkO4w3HjKYabyT/jd9SjL96jFaVGzHHA7yjcy5v/x130aiB9T+lC6kCAwEA
AQKCAgEAzD/HNuSO7ukZt/ho7GEhwK3o8Lzymm7U476/r+KzNPW+JnJ6N3BJYgj5
Plj7Mm0+pPff+YEBo6jhGxLw1IN8StAH9CTUqUC8Bcth+rWtTglV/GRmRW/8Wrip
iBVfnRyTSImSCPWQBl5aFvecKfhdn3U4QpJ7jLXMJjG8ZXtx/Mw9SflkjpB/yCe9
/b5b/rD3Fo2iuWIhw6nq1DGEjv6XzIKZ3hUOpbLoJiwhwIMyeVwJOZCZzR8C7dk6
9fAz9cwtt9iwV9w3JTAbbLwYXVocQW4mDwZ2SvYd01v5ZNkxvbRqfUtzxvxChsfo
UfjfEEAyPofE5+qHiWui/Ytt1jz9jlWF9fipq+T0kumpg40ckk9GCqLUFGQOYqOJ
nwKL48sZ2ZTu+53wGr7Nj5Sd7yyeP4n5vAkiQxgsWJQF5+XL4U7omgKVWSDBaDcb
jEkh52ZOSlFn9edMMlUrvtH4yRrSTVkWgi4nMr2CLjdWwmWfbiQ+3shnlKJgnp/U
oVEn1lU3Gnk8Xk26KsmbmPNoZ3jNGLDhTwInqwuC6NAtgCskNavpr615KHqLGRqO
s9EC51/5bSfraWcXelpvJ4Bj8rzao0QKq7nBeQLxF9gU/zqshLlV35FnFDDTy4uS
cvOMEqrzeP2ydpqNwfSquntuLGRkJqXm9iGsAvNPUV8qqqAYR50CggEBANe4JI4r
6IX2Zrp/DUx7fBqGVE9o9pXC/szJEAt8eI/Pu9y6gsZ+VnlFb3ZzrIrru0sih0/x
+zBYHIdTf7iBlL5BygLKDH01oTaheMCd0lqmxvyXkVnmuNBhM1dJOmOLN8nDrCdQ
VUr936TawZe3kDKURXB4c7k+fH6L5cA3Jt5+VypTxrW2aNsXcDN3QWCcSkngyrvk
/TfJNbJWIQireckfsajvCYIpy77U2ol0y7JoOkXmsNphWzIuYJPrcqmCVmYrWeFR
BoAVeyTPS3ho47h/Meay/saBJzyI8gBcFAOjk5js3tbWZJtUfvh5/iye8XYB9GsA
shAComeoG1yG62MCggEBAPTv2mjPoKwLoWEYKgvrIWeOd8APMexmlex7CqGmwXtP
aCtIV6qbuiJLFZPxIdxmLtZdJmQulJiCnEVdGF6OcK68myqWrHazkG9BJoOeiVDF
9CD+9ab/scRbCawfe2tHnv6D75d93KnmNlRCracuNY71uqsLxnDhBw+Tbnc4cqzH
/qNurGCIDQRcj+1Kj0i2d62FUMOlYnkI7xRl9u8pv3ZzGQDIn1363CGWLk9eHFcM
VYbKRH9siiMEutPDgMf3QXmokEEqW07CZWrflm2Hdukl6R45jxw1bAplutc2PtSs
R7enKLMetg06ZVX0xzhZtknghWNswalVknpRr+CaiIMCggEBAKgmTLBZv5V0vRzQ
XoBonRNb9Co2KkgQyGa+r3gUnTGUft6Or9OjtSowmrLddfiPyd3GW21QtTk45XwC
9ULQFy66v4mvD08mV7Tq5uJV4xtwdxl71/wY4aTkr41xckcXxPPMR8wZTXL4M7Ug
I9lsZ8VVWE9URPh3oblOuVc8Zlr2ZmGDDhikyFVHjtk/M0HocevmgoE1/L/YYrfR
dUx5xaOlxell8qZ4h+4HoxWUahd2MT49lUuUqe6Swgtrc2R4SXq4fgYpD4UVuXi2
8SA5upAc7bvjeL8o+3mvUdw/6gXwIuQId6dFVQTTN2neRedoOdV/rpMd5q6eLxPX
sQRN0vsCggEBAMLNvJydfYE34srRKCfAgxnUkmM68o687EJffY4hjUJgXk4GREsZ
fclmhCvcnPyofFnbTfxhm6dMQbNdHlOd3/rpYFNX8KSbnaUOYO5PeZC3T7mqbX+7
Xwv3B9NQWp1xIf/0uOp4nLa3tMABJBGRy+D+iM8fF12Ra0c1D6dcSsAmc9xR2mEP
86JjZ8jnAtxm2vozzI8+CvqOY2+KxQFj57XyRpF7/lwFd2xzADP5enq1AZSpbB8Y
GSlOyrQ/ij3/5aA3sztQz7vtGjIMz5wfIDDACQ8T4kEiL+J5FEe0CfalaoijNth2
9X3B0vSxMH0dxMAvBIeV6NSfjVchfssYvLcCggEBAMXXX2ISGjwQ+uZKq7EvVsLj
7WmTwj9v48c3CuZG/eBblm+BbgDhsPf1QE3APqLe9UU8zvFK0X9dMkyNEPUA0TL1
Ms+T3rcK5p2fdHQJNqmKoXkw3JhLhyoTJrHz8buMyRpC0WtbdzM11y/Tm/flcGRr
fS95/f6rExFvWVzixnmgAktgTmgupUdk2D/BSmWfmywsUiVIQtLeDkQBm7/mgTY2
P4PFVIzpX2dqNXiUMHiRKmj3OlfAW+xwRWW29/fzbXGEmmvrbHswYzLb3qakjlrB
l2tlGP6VKr2BvJF1nwcrqxjIVVzHRrIAStZrvfCcSbYZZvwi+5GtZhu9d1u/d0Q=
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
