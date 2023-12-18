
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071228032482"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071228032482"
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
  name                = "acctestpip-231218071228032482"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071228032482"
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
  name                            = "acctestVM-231218071228032482"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2622!"
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
  name                         = "acctest-akcc-231218071228032482"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2Fl7xJIQsreWiaN3Ry4ZBlwqEw74nCKxsrBEdvzR5LHk0DAJUU+IvD5pnvOdg3/m0aM+ZT8naDIbZ+nGl6YlCn3QyjuEW6FvPY6bYD0CLGPKEbEbDZkAelrtdVH+iaDb47a5X56RRubpzrsP6lvqTvgnQQ8pHr4WZQx0FldFST/Zy9ltLg6mdyxbe7noVc6vmk3NaE6Pso+Kfp6G9UsLDVD4uI2r/3x2MeEf3KdudxLTqSlUlkBXobGnzDPEB3ovudlNzYviXbdoH0TcC++A04MYTuP5qrYsSOqquFqRgVhKBTWDPVHNTL+TM8HQvY6azV0v6DO/MpGR+8L9B/vFqnkPerrWw/ziyljdUq7oPwGXBeNECtMSQ0RQT1SO6dsuzqGa0BJ/ReaKUfEZjm+4g40AXjOl70aQEs070UHpsvBEZ3tJNfKppshPoBs36hul6QiYaZYE5oVU6zJdz7WgaKfM6bg+ZwDPrerz9giQdZistgPzX7yv4eHbmuo5phubY3bqscgrm2aQXgRCEfv4OHGt6Nu0Ab/ol+4z3lwFLpwa0rPw4jRrszpHLTtMfglhOMY52ZKVeDFJl1U5L9og85uCKHDoYvptwec5R3/adHhLY3nDp+JlbEHT/K8LkCOA4zL/3VtS3N3uEio9U7euu+XKrFguJGvFhMaXZv5lLncCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2622!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071228032482"
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
MIIJKQIBAAKCAgEA2Fl7xJIQsreWiaN3Ry4ZBlwqEw74nCKxsrBEdvzR5LHk0DAJ
UU+IvD5pnvOdg3/m0aM+ZT8naDIbZ+nGl6YlCn3QyjuEW6FvPY6bYD0CLGPKEbEb
DZkAelrtdVH+iaDb47a5X56RRubpzrsP6lvqTvgnQQ8pHr4WZQx0FldFST/Zy9lt
Lg6mdyxbe7noVc6vmk3NaE6Pso+Kfp6G9UsLDVD4uI2r/3x2MeEf3KdudxLTqSlU
lkBXobGnzDPEB3ovudlNzYviXbdoH0TcC++A04MYTuP5qrYsSOqquFqRgVhKBTWD
PVHNTL+TM8HQvY6azV0v6DO/MpGR+8L9B/vFqnkPerrWw/ziyljdUq7oPwGXBeNE
CtMSQ0RQT1SO6dsuzqGa0BJ/ReaKUfEZjm+4g40AXjOl70aQEs070UHpsvBEZ3tJ
NfKppshPoBs36hul6QiYaZYE5oVU6zJdz7WgaKfM6bg+ZwDPrerz9giQdZistgPz
X7yv4eHbmuo5phubY3bqscgrm2aQXgRCEfv4OHGt6Nu0Ab/ol+4z3lwFLpwa0rPw
4jRrszpHLTtMfglhOMY52ZKVeDFJl1U5L9og85uCKHDoYvptwec5R3/adHhLY3nD
p+JlbEHT/K8LkCOA4zL/3VtS3N3uEio9U7euu+XKrFguJGvFhMaXZv5lLncCAwEA
AQKCAgEAszU8LlGHf2JPUeeTz+RBWmFRgMPv7vVWGFul+qHlAvjQPhrsPOwSqUtR
lhbZrKlvessrzhYIAGkxBlxA4jD/kbcyEbJHKteIG4da8NbYTAjEwu7fJ95K5Q8Y
jwvCOiKCwhcDak8gq4hut41/23MTnSI08dErEIoIZt9v8WmMvOYk9JQ/udzsyt51
UQFnkFxKXRiBQxuAMDpyT/vkcp8cooUl4UmI5XIlPZ/rEo2mFQAFT6QqquLVM9zC
z4U5pa/yhJGZvt9WPKbFmtEhLMnQ/mMi6YYxstR/zk6D530t9eQ6PCJdeZee5Snz
NvYegEX1uJKuMjta7vph4BdeHRTSX6NObR07NqSz7CYYFxJUy06kUKx6Lj5oeB7I
N1Mc0D6wZ3odxxJIuoWKXx3EXdUvVkhRlQFsb4bR69z66tHztd1ma2mCs+rG0nLG
J9LYZHl3u2J82swx6s9JVl5ncQ0/Brc8ohXgDZiB6jfvpzVvc9yijZRV1Xe0L77f
/bHA+19sSoi3NwykI+BhBHCfQyoMXv0RE72oNU6z27vmA4FU3ktqHMMEqI7XQc4D
ykamuRXAL0ruWUCu4d3lbWN+HdaADrV879ZtL6kfunpZRaJ6J90b3eeRP0PUKEC5
jB4Ppr3fsagcJEvNomxtDBv8DXQkxqg0comw/fULI1nMlt5LqqECggEBAO0pY0y6
1gs73ULwkQXUDZ+Lt0CymxjI+alyhUNS0QXPLrI+amOqmykSezFTJO80pey7LEwo
LWLiw8pSjaMmH8nGdbilPz7svhXq8V8EkqqxVHfjEQlJhWc+cb2FQnDaNYB3jxKa
U7mjfGBlrAld1l2418fGxXlDcwzbP2vc42vF2Uj++UgZ751fER180iMxsopBZa9i
Lk5Wf+eEadjsJfQqtrZZ1WdZLL7Y4eljFRqz42EDS/J0W8nrJ83SY9lBu3nxXO85
PySnqRwUis+dHPRkvTEZUJFoBQLzz8GKA1GzTqrhO3tIC5x31+1vuDuO0k6ppDgP
I4I62l9A5nJ+Ut8CggEBAOmI4x1y+UC0V9m45X0lvyala+z1wZcwLaTcuRppNgbD
bawDjleK+YBlDr5TNTc6AortaNG+qSKWf/6WfnWaLkGMuEGxK6c1mTW3DgH7wV4N
uu6DY/T5q30oK2vSIaunKSyBRT6XZHPaIsNCPyU9zTo5c/JsJMu9NQfWrUG5Tokg
9FhpN73grmVf3pK31rnohNJwO+oZ4gx8y59YZT7b4ayV89g8Bz+Nmo5OJAka5fuV
NlUC7JYygnCYpBiOHFQuX1SoaihHIPAoHHZHn9askPdVsQxCrNryk1V3E3R9vtF9
YG7Q2T0Oa09dzBwwK2Pk254c0l/hZgI4A+n0lxyp72kCggEBAInPHPZ/MtWAScgW
Bg8+81OcWjXsExfJ4NlHxIwkWXVouJe2kRetEVBCfvdgevvMugXflZQDXKwzXNX6
NndxNdOH0OwkiaXE54fQ58Tw4VDyjkTD2yhsYmpl7K3V+4+cHK6zyp1is/gRObrC
Gb+vmVsIh8p8hE88lGQKGsZQqo37f5FdJ/lvqL7neQiLeYgd3sNb0Pyiromy1cvw
M5lrT3qcP2Oiu9C8DrYvTMbTXnYPxbaftcgDOTsRvCVrdb3O5mOrjvcraref/TJl
9WtCvop85zranOiBazgV+MlbqyYUbUf6bRfr+2NGeGBuJL3m9enjxZsVoOqRzEbB
badmJD0CggEAfNnW+d6GzQXdVaPY5MAyYlnbyjJUzhxOuq3aM/l9jb4bOvQnvDur
Se49JJldgOn9hAKKoF+7Eqe9RAF3GC5WfmrZ8xziBqHMCACWd479gOf8QRlzbfuw
p9e65wjPQXK7u3Rc7aqIZLuBDDy1f5Z7yp3+k+MnBNlhqZAmzlVgXEWG/GE8EMI2
2jGXz36DSJ67q7me/nfZ9u0c+1KJxkJNczQzyi3Ffj+ZGm1CLK/5tje+dVJ744yb
WdDxIcOP951XD+592oy0WlBHbyC5nk5hrilc3v4iZWd8RxvDBetYAa1yyavUCCVW
T3cI8ST7fYtTskMcYXAiVhtWVFSUGRnsyQKCAQAIVs4ph97J7kfWz18qcw+bZ8fF
QVHGg8XoTF62c5dB5lkt2DB0Tpkz5TekWX+cx5F0Ukpmb/WTZ2pBDVGMjEsU9Jiq
eNEqz/5s4Ojmjzm4sUhaNQ8oZ+ZwHKvxc1v9FHA/Pc/rHYFQ3XetOAPk0QKUhi5x
gSYJkyoz/nDWgRT/wgcMbhIua9FSDsKbBTyULvF0BHL0TQfpnkRk73dA5JFIsx1A
bJVbvuZln+Vd44f7OAhLYI31p8SARSXgRXDkxlc2ciwTSfLkuNNL20y8NbuLf3nY
qH6bLIQa6+vXeR4bb28Ar2SgyOO28KCphhWxBrbpuHm0vHIyC1niOQNLKghD
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
