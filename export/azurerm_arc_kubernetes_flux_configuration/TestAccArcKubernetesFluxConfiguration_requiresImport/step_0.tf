
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023529983399"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023529983399"
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
  name                = "acctestpip-230818023529983399"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023529983399"
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
  name                            = "acctestVM-230818023529983399"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3436!"
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
  name                         = "acctest-akcc-230818023529983399"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtDxejGIx4zcxyYHNpeJ0wex1UXlu0a8WH4dardnZhZilHBZCuetcxYPHKYlvbVPzMjtGdBv3+xwULy1z8zOAMhL9jR0swwoE4Qb9tGrTus9duqeouqN+hi54IWCwSfzslqvXlKm3UFfvvsQc8FjWbtqB2t2FNJAPZGsWGsy6uUEuG1vFlmiD8wrSvzcKjd4N0woGeQbXg6gwxZE2NhihM9g/66kZTjoo0EBj6hLt1mgiA+Gy69G43A1OhiL4ye1ktbePXvHj+msM4B1wR2FBOvqVChZM4EieTwQOdMYB9e7+iO6muk/3fjO08qNc/qVN+rL/YsXz2GeFnb/opF9aLtfG+7qUDSqNrLdW8Ep64zaIeopb+XfEWxu9hphF/8EHOkN0E1KsH7sv2avP9H2zWFIityFjDDGPxCBwTFHSW6t/QjFeqAPzYI/ltPCD2+lCpHsydC4N6dN2vK5t888okBvs1x9KFE0U0gTLnkGBbd+6y4hELUoUiOcjIhlH1R8Hp3RYl+CqkrMvbaU6Sx4b5eEVl4o2f6YdBlftd5oLuYEKb0gfre5PDz09oBKt4eISIA/N7GMeeTAYTgL+DeckIe/ySiFwg387SWDOKWclI2R9So4ZvJ8G3R3qMFtJJ74YbE7+tJCN9E1VE9EqlbuwEhHFs5KCSAWbZ06pH9jADMMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3436!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023529983399"
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
MIIJKQIBAAKCAgEAtDxejGIx4zcxyYHNpeJ0wex1UXlu0a8WH4dardnZhZilHBZC
uetcxYPHKYlvbVPzMjtGdBv3+xwULy1z8zOAMhL9jR0swwoE4Qb9tGrTus9duqeo
uqN+hi54IWCwSfzslqvXlKm3UFfvvsQc8FjWbtqB2t2FNJAPZGsWGsy6uUEuG1vF
lmiD8wrSvzcKjd4N0woGeQbXg6gwxZE2NhihM9g/66kZTjoo0EBj6hLt1mgiA+Gy
69G43A1OhiL4ye1ktbePXvHj+msM4B1wR2FBOvqVChZM4EieTwQOdMYB9e7+iO6m
uk/3fjO08qNc/qVN+rL/YsXz2GeFnb/opF9aLtfG+7qUDSqNrLdW8Ep64zaIeopb
+XfEWxu9hphF/8EHOkN0E1KsH7sv2avP9H2zWFIityFjDDGPxCBwTFHSW6t/QjFe
qAPzYI/ltPCD2+lCpHsydC4N6dN2vK5t888okBvs1x9KFE0U0gTLnkGBbd+6y4hE
LUoUiOcjIhlH1R8Hp3RYl+CqkrMvbaU6Sx4b5eEVl4o2f6YdBlftd5oLuYEKb0gf
re5PDz09oBKt4eISIA/N7GMeeTAYTgL+DeckIe/ySiFwg387SWDOKWclI2R9So4Z
vJ8G3R3qMFtJJ74YbE7+tJCN9E1VE9EqlbuwEhHFs5KCSAWbZ06pH9jADMMCAwEA
AQKCAgEAg2VngGyt9fntH/yzkfXwLNhYBxfCRLeiJ0YkQ44IWK8Z38oSxzvhHFWf
wpZhV5DWQY6ZJFinhrfHt0UpvOmU0eyqUFAuq9oICI1yNC+VQCGhMUy9Y6OBwAzs
o1i77JSpXobU2ZqI+9e//pE2j7oUSiiedpL8Y3+K2SiAqvUKQ7hTBrr251o2p98C
GUjlNtvltC8g3OayA1eAhugAX5vBGezTXNigjDk2O+xVavZ10dOEyNOn/uecH0DM
OFoSihO5UgkKSquKCqw0bMbJbiBmz7qTIRF05iXK08wfRd5823BqvCVQA4/83FKR
3jpet36HxPbt3HJ3/RIrhP+9eOfS9A46tAkucmpe/iCGBLLAidTrOk5zRj97HZH9
XaFwaYVk2iDJJp6+pN1hYPNDqwR+1O90Kwa5Jg4L+Qpmtvr5E76qRRg/6KKLlBCP
WkgJUN+2sKrmslDx+zNbstm3Hn8KkIC53AUemMHq/5vojNYcS+hzeReC/xvPIji9
pfp10I9xzbGpGk0a8asHt7+Uc0c1rbqfTY7IF4U8mw/iPXv+j+OtOEMiOgaj0fBF
701OgQ+BF6Rj+KCH/8LEF/jN/kIYbi2oPe1Gp9JEw50nhHRBIkwGvOc13p7MTGwh
5VH3sN4jVuHb/NQB9FTkmglce+riAsB/logFeoSMGZVW1LlgmTECggEBANot4qD0
+KvErtOE6d6KmPCmjgMOsog5dPCLfiOOIItlrWZrZ989sT1Mj88iaFU1i7+Q9Ikc
WJRSu7bj5GO41fnjY+kQMG0R+Crm1/vKMDoUAaIT8zogR6SXP7CSNB0+W/4QDcwT
VwJ2fDp/j+ryo6pN/glDiMDyteZ5Ffd0+11cB5jdOpnBnP1MCDORhZfLrM81a4BE
T1rcDoXNmdIooXR4+mQkX/hIXdik2w9sZHLHeuMzyyEFD1la9GErQY6MohVdVfk9
Xr9VlEOu+cTxdZfJaEaWYCkTWfg5oEInEieKkA13xDwsdbzPGAUFoM+zB6FpFjXi
l6mAspymGDr8TGcCggEBANN6rFo3XB4+69MwI6FERSSPYYewnOA2CBniOzbiqBuR
MyjonCYQa5Opc4X1eSsK7JdSS8o5POS3K61qaB0qQdRMFlYVC3tLuGE0g8ddmkaP
3MhBVe3ZvlEVyUiasH+eL2JF3aNFfw9AfCOFAj8lv9IWwPwoKS1FdJ1eTR1gpG0C
n5eiF9AzHKoEmghDmxRaE6sns682r2caxhhJkQpnCGQzFv45HApKln6mCd5ZpHPV
nisoTrE74s9r1qoNvhUQrVVCTTugC/VAET3alTbGHPwoyEK4BYmvguNCEh5xZsD1
B+AUa+YCnG/VeLo5WoPb9jQ1stQZVi69PPoFzg7rw0UCggEAQrtYHtzuljMBOgbk
NUH1B14Z/4tmRc41G0G/Igbdo2VFBReC3MAUzuf08GjYun83MC+Y67r0yOEJMyY+
+9VT9St8qpNeDG47lnumwgeUep8V5MnvUe7/mrL8Mvh04iDpqCqm3a1opoMw+f98
OGNgdb2HHrQ+Rq21vzl344kvPN3iIPpBazfR2ZOAyq0OzF/qijIPoFrEXskB1CEP
lD0DLQm3pBuQEvOnaJT7v5rqmkSzLHzx+zZ9/Fmad4HwejY/eQNkQWho62K0h4Mk
N/2WdweOUlC6NrYJhaeygalLnzZ9WvEv3yvGEyrQcPDIv95FTjRDK9YThy+q8cjH
jnsOrwKCAQAstvZ0SNpIZuN0Duypr4azGUH078nrumDyIByHGVuUIJphnvVNMxGb
8itD+sg46qFlyXfO9VVDwtsQWrxS1ll+6uuaHe8EjdkZbIIkiE0TeF2lVfM2TGDq
QiICIPsKsMayD7WyTQJ1lhvpYrk74t5xLHB3oII8WUAz+flyKbn6dqCJ7jL8yaHY
7QoojyreHcGk4csjU/u4YDfccMmjGm/yx76n2Clun6C8fJz/j5KvD07XLzmcTd5C
HzoPUMKNL66GpXMxFUESBQ7gNjRwlWkRhAn72W8KUrrpFFJCb5XbXLPilE7QHmM3
XjqdnXze/oZLOcNrB0Rqs4aOEuYjz4PFAoIBAQCr+mWFPkxlwNJ/qyUYZQEN3sfb
xALX/RV6oRlbw7U7xFUGLVcfKjqCTniUrNClwryM7vjUj/FlK+GSN3/SJXuShO7u
vmwFtYSntI8+lgkqV/8bxPFEVnxqC/JekMRM5QoqZKN7pgV5bmMuYLDMgkMhH3Y6
SyDcO6xTEny26EvxIoq4+tbqxN5kyBmLR7L5FVtVQ3RRSXajzyWePfu73Ow7RnfS
PmbXYCQ6txWnI49qTHUs37PEMwNqAVZ7f28T3tdiW1BzZKzmSiDszitY/GRIOM3h
cNMkDgFCxRhJpJhts9iV3l1oLmH3f+R4eS9siqVFcTZWr2gV1/qAnCYB9soE
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
  name           = "acctest-kce-230818023529983399"
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
  name       = "acctest-fc-230818023529983399"
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
