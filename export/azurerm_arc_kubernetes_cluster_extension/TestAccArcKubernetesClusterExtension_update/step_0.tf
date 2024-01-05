
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060231991298"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060231991298"
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
  name                = "acctestpip-240105060231991298"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060231991298"
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
  name                            = "acctestVM-240105060231991298"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7410!"
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
  name                         = "acctest-akcc-240105060231991298"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2NmtNT2tbw7fLycKytkIQc5yTLfoZQMTsgXcdVkqsH58l8hoWO2X1Jr0hqVYPAXOKzvibBbUMHYRtMxghS/BBA/am22bAjzoAavYGq5yYqYyu3vMkNJel9dbsip82GUxyiK4qtZRGdzYQzLkz2VEXLaX65vmessVyw97oS4NpY8xvHHqlF8SY4VkaLuj4AcT7T86zAd7+ofVIZgU3KP6yyjy7ElFdNTd3ey8Hj+2OuXb6fgPPCdTnhmC/Yuh0KD+DTdqjGrdywUT2JhI117NKHVhkBYFtN3r6InlvC4snLVx6/1n4qD1ei/0M1np0VmQO8KExqT9Oj01ghFeFsXAErCsq9suYNwpPR02w2+KveatUnWTE3tAXrSfGWryXdnO6Oild8JMFj80uFMZ0WrtSk2wMgQbG4F3x1t/EegcDEEtpnHFt7b7SiLZG2eBHT0yNjC3fLRmxpiKEabuBsnuBdUVl8MN2nYsD9E2UozKQQrF75+qktwhMl0VLRdI7UvPDab103d0DCG58jKxctaNWULAdGgeAXWpFrMAUHphgGX6nbTF6hMrXjZqwa1S+h/0SZzoKn1/lsC5MtbnCn/s3TYm7JD+EZyQHLsoWJgUoKTWxjB7PulpUlQOofQR9xL5BigrV7ulD9SRL8DccgSsMSOuX9ehgzdNOgmhL9jw9nECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7410!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060231991298"
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
MIIJJwIBAAKCAgEA2NmtNT2tbw7fLycKytkIQc5yTLfoZQMTsgXcdVkqsH58l8ho
WO2X1Jr0hqVYPAXOKzvibBbUMHYRtMxghS/BBA/am22bAjzoAavYGq5yYqYyu3vM
kNJel9dbsip82GUxyiK4qtZRGdzYQzLkz2VEXLaX65vmessVyw97oS4NpY8xvHHq
lF8SY4VkaLuj4AcT7T86zAd7+ofVIZgU3KP6yyjy7ElFdNTd3ey8Hj+2OuXb6fgP
PCdTnhmC/Yuh0KD+DTdqjGrdywUT2JhI117NKHVhkBYFtN3r6InlvC4snLVx6/1n
4qD1ei/0M1np0VmQO8KExqT9Oj01ghFeFsXAErCsq9suYNwpPR02w2+KveatUnWT
E3tAXrSfGWryXdnO6Oild8JMFj80uFMZ0WrtSk2wMgQbG4F3x1t/EegcDEEtpnHF
t7b7SiLZG2eBHT0yNjC3fLRmxpiKEabuBsnuBdUVl8MN2nYsD9E2UozKQQrF75+q
ktwhMl0VLRdI7UvPDab103d0DCG58jKxctaNWULAdGgeAXWpFrMAUHphgGX6nbTF
6hMrXjZqwa1S+h/0SZzoKn1/lsC5MtbnCn/s3TYm7JD+EZyQHLsoWJgUoKTWxjB7
PulpUlQOofQR9xL5BigrV7ulD9SRL8DccgSsMSOuX9ehgzdNOgmhL9jw9nECAwEA
AQKCAgAu7dTdS87H1RkZ1EIyqgtuamY0EizaB3NwuHIAd16UuZrvIjDq5ehQ24QF
y6yvuLXoh1o1+C7Nmg+05/IPgMktvtyZfHvqXRH8oprvE0ev77XU+zLHOK+9/p5a
jXVdQ3EmBKOgXSdKCJBI4q+/7nN/+QghtiiH9IFv45bmx9euN7IUzTZuC7EoFosn
W0xYxE9cra1k0E3VZyYJ0ibZpSc2ZlNELYs5gIPPblc72J/wWSRhmwx5AS3Ibk75
3gkT5HN2msKVRt9e+2dTHYnOCjcuBVEq5IkxnkFantU4B2oiM+ZGox2jXyAg5FXd
8xx18QMU28DuWHBw9SQqVOXe2cb6Hn859OqkzU0gvHMuBA3fh9AGpnn2+pWDB9pO
XQeYcU5sd9fCYsD7bNI+yHUTTW9LOFK8Bu84sQBqjdLy9AYiNwQ3zWxxhfIf7YPy
epYuwowmzpYZA4EoWUosH7e1iCVqrVVXAH7kMzgg5GbvwbF/STqOUgSC3w2AMM8K
MHh8yo4Y+YnZ8oEwp0yi8OByY0v6rBvKKlIxOdgVssL1ILoM2WXyxL1Zz+xO5NZ7
blRO7AoOO+4DY48HxiSeutdP6LL5cfA5KY5zyizYOuIhprHgvKn5nGeN6vfp0IFQ
kWL6dSAQUFo0AzcErt71HRoJ2rEnj4KsBgEc3lAr/t3gyViD/QKCAQEA8J4dNCRX
4MnshxxeLX9IxXo31gaHclQbbYG78p/2oFxacWIsxYg1LwpwTXUJQM50n2Y07JVn
/UjUbBrL20DFEy9t2WnXxbIlkswUJg2kk2uE2BqPk31QsaYWumMJrndC8Eg0WjTw
YzuWMeXMKqKPkRwRHJGcPY+sisDRp+93m/p5GuxCSWDTmYjXKeblj2TNcD/Oh40G
9XLQH9RLLRSWLnUNjqiC557FW4FzGLGHQ1NP8QJWunYrXH5HrxptFwxpKBXuPubM
NndjRvf+8FS54IcrmrHlEd3E37FyHNg7FjXbH6j8pNKJjGTGFp903S0MHv/J42a3
bDMoMJ3vr+hL5wKCAQEA5raXrMAJPFESpandZKFQdU0yFDGRYr9vIdX5bpyiKKCk
Q+ObXy8Xc19ospAnw9by2y38s2VKY/HN6SMsDxx4MzzbaR5A+JorqapwyHgxskLZ
zOjQlLv6TphcuDzYwfS74Hzz1CxYjf8vA1TaoN+aUoQ1GsXYnEmXCRaggJMkXy+d
IJJ3Ranlw9Kzb/mMeGjbrEPHd0HpHkSwCuJhLleEjWydgugXkM5o7inm+m+lEe4i
Fc80f5PD2bDk64MjhPI/cQDRq2PeO6ZtCTgn96V8n9ZppTKzoVOexlgBWZI3lyH5
xJQcNteUj7F1O9xxAKvirGDV8kKBcErsxdP8CVCf5wKCAQA5JnTtQ4yT2aISXUyJ
JehU7zh/30EgiJWTJvNLJ29em1DoCVd0+2sWZzZRT3EJMYBFs/LyFnKCmF/L5Xlx
9Cpa6jL/JsKXND70ZQCMIUVrtmfxJC3h7CvUZgyT7J4KEE2X4K5+loBaMXb1Fw2t
Ors6zh3KWVNw08U5l560co5IP++v01nTL+pSV0wzqaHwsxKQjLczPu3eMoz4YmYQ
qQkas7aqoZ+l//IET/TUcqYb+ZfNOK78zsBx0ZSZJH+wr8PyP3M9AXiTnzu3SYQF
9TnI+JIExigQXEo8j1r5Ouqd1eDb3jlTtKXy8KSUDv+k4OQ2IK8FEgqS6nurQHgD
ofsVAoIBAEz3Jtw7aBlWFnlrlG7onbW0Hfu8mXqu0D0ia8apvDL/fC0ltgRn6lPT
xVKkYo+jmnrh+YZDSTDUTtPyptUXs0WsjKmhrR0CGYTNVjiaWEHWqWABXuvvVc54
Z54StmDl6vM13AWxEY21TpK28QRv88SJVEntLJjet+MRSFP8Qkr60Fk4Y0+7IOpV
1QSK5ICawoXSSq2PMFynn27SHIdgLNkdHeK42Hu3UCv7kJGFQzUbEwXhjOrueYya
xZOHuQa15dIl6sxZUZ7mo0NLF5I3A78ywSWaJ3CvO62BWFnwPFlPvUoF+u+UtXvG
QIzKumv163WEDHt4EkRKyngogtD8s4sCggEAS7VXNclVgvVIf/79e7EgVR3Znjk6
x91MK2t9v0gumYyjFCSMukePf5NW43DzqZN9jxarIfrEgs3NVgH//mbsabQ98X/m
kbxOjBrNEUThqODkCW5cLsIqIr6+0K7CKUF0il3aY66Tp6y49Wz03RXjwKQ9z1TN
ELqkEIQSzqDBtB4JFYAt5Lk6wp3nUmfJZk7bexBTBLOV/XtfZjdKyYMkP4hXGPxi
P7259x1gvDgWFJ6ifrn4titkmAqeFs4UQC5WzdzzBgL2YsISYQMiJmhqlIau9BSt
+Vnfge4/O194sZIVYGHbjY0JuKEwX0cAv6GIN2GNd8rdP2Djwh5pqRcj0A==
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
  name              = "acctest-kce-240105060231991298"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
