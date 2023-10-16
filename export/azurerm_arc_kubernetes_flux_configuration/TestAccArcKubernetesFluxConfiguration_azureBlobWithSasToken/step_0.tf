
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033404920036"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033404920036"
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
  name                = "acctestpip-231016033404920036"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033404920036"
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
  name                            = "acctestVM-231016033404920036"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1452!"
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
  name                         = "acctest-akcc-231016033404920036"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAokUwAvLJ8WKJDABVRwVEHQJl2jGsIi7kOaaFjr3iXB0pxBZx7imtUjIgZSRW3f2YXSaAAwUgOB8NMnxrmC44Qlz+qCcrj0AZsy0rYEDi/mZiFdnMJs17viLeCah6oTBoIe2L8ecQLUq3yw4HZ3oaQfJ6AneIqrYBN/US/oyWEHrppITUeQbdpjztMZNhPsK2OCd0l8It0nFh+IVACVZarUVGHoEQBq1BYmSzCeS4FTMdPNs/wKIAXKXE24viWIMO5l5myiCMHYp0MhlBzgwcAcIhyQbzXiy+pmSb1kv5vxfemk2JsyefecSBeUT9RrzVL6wW/d9FLb5zLeupMAsx37BhTztqcjbqJmDTjf635bMbwaNDZkJCRLg+PoCeCvvVtKmY59ZfQ64XL0K8lNB6L9p2/benehbbZaR9GarqqNC6q1XWazfOiN84gpRVKwSSiwXr1Jo7ksnBkubVOS2vfPW3DQq9EJiVPxROjOS/pydOpOcFUyFXArEYNa7GvcQx00yCi49RWA7flh8JS5rCImrGPQGGhlfTupmkx03Amq4F2VqOdUjCJAzvZyH5yWabXYAh1tnUam1fl1ffMoStXb1TDMB1wj+mK/k0qWqGrehAqiicUy461UNCW9+C3GhyDli4SPj3fUgNyohSoz15S1ECugx4lQBLi/jYvvPiLksCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1452!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033404920036"
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
MIIJKAIBAAKCAgEAokUwAvLJ8WKJDABVRwVEHQJl2jGsIi7kOaaFjr3iXB0pxBZx
7imtUjIgZSRW3f2YXSaAAwUgOB8NMnxrmC44Qlz+qCcrj0AZsy0rYEDi/mZiFdnM
Js17viLeCah6oTBoIe2L8ecQLUq3yw4HZ3oaQfJ6AneIqrYBN/US/oyWEHrppITU
eQbdpjztMZNhPsK2OCd0l8It0nFh+IVACVZarUVGHoEQBq1BYmSzCeS4FTMdPNs/
wKIAXKXE24viWIMO5l5myiCMHYp0MhlBzgwcAcIhyQbzXiy+pmSb1kv5vxfemk2J
syefecSBeUT9RrzVL6wW/d9FLb5zLeupMAsx37BhTztqcjbqJmDTjf635bMbwaND
ZkJCRLg+PoCeCvvVtKmY59ZfQ64XL0K8lNB6L9p2/benehbbZaR9GarqqNC6q1XW
azfOiN84gpRVKwSSiwXr1Jo7ksnBkubVOS2vfPW3DQq9EJiVPxROjOS/pydOpOcF
UyFXArEYNa7GvcQx00yCi49RWA7flh8JS5rCImrGPQGGhlfTupmkx03Amq4F2VqO
dUjCJAzvZyH5yWabXYAh1tnUam1fl1ffMoStXb1TDMB1wj+mK/k0qWqGrehAqiic
Uy461UNCW9+C3GhyDli4SPj3fUgNyohSoz15S1ECugx4lQBLi/jYvvPiLksCAwEA
AQKCAgAIyEvX7QIHAXk/YAk9hchw9X9DtuqFExqhECUsW5STvbRT+48A/9p0l2fv
cW8OJrqHWB0XjMB4qR2SvO8p1l6PIO9bdHtEDokVjH1LgVeHw0zNt/L3qqlm2gZA
aZDxhmgsZensFsBmYyPdZo36CL7BEPmPhp6r9pvMRoRXqI46qBxbHiFNx5RZefSw
eTSLLAims2P5DrZiLGbMB5I2ryjLNfOclQmkAt6GD8Ms5ucbpp+PeqJRr7LrUMF9
zG1cswMsbrGLgQV0V9kAGSPZnggqBDLF6Y1kbHGJGerhR01mDUmr+kRYoO1drsf/
Iz++A1xabyrzZJEe767WLmoCwqhZR+dsXTxCeEoNJAaTsWrcQDKJBmjQ91qojrpB
WyTqBbFBpLyJlr4zVjGmGAUWCR7LNPh7iYj3/mGZNlefDjJJoru6F37uBAQZ5dtP
qrbuXm/uldFnWQKJtVo87q+aNGzNWMPijng/f807h7FIexYOHodAwjE6Dr5cdYDq
cjaYmU1PwtmawSxfBtAlwNobCjWLZcQ4B7APYLdc0Uvm+nt5C/lNe3F6r21s5BGl
aC9ZFiJP4FETw+rKuhRyGBnS2/AglHSB1UHDoBpeAd4VgmdaUqEN8pvpaDzB9JCv
E7ZreySupH4hwOi8l9unNvyd/Qz9uK4tBzJbs3Oq2X5qlUJdeQKCAQEAzXAE2Art
PJ83VES5xPyHDP2c03UOLVf+5887VTakTpk506Ft7UGWiVo7LizxiaOhfPco0aGS
nBA+xsQtvP7BsL/Ziu3ROqBgF80BYGwjNSm4ZfEzcbx1zm99E0LHZP4TbQi0VF1S
X+IOmBGcWRsA/LKQGuPilDc/DOFcnrmnOpRs/0ByQncKAvHjKzr4VE3BOZYFEF8F
NuyTuPHmU68ZDszqPmgfuTWuEYWYbo5p1Uq9Vl1ib1d6qFuS+DkNf0Gv2s+6pSLA
CDHgWg6sGvO/pH0fnh3RCSr31ALqRIam7qZYvSukFbuVcnLgdRDaxYFcohf3ghp2
s1XMfPSlPLB/pwKCAQEAyjVUu9AhswUJ5GCofRooXsDhHejOAEzwxAiFDaYbpP0D
0mrJSAocjRouWS9tIa5U7pdAXSUwfoD8k5ysSQ1U0890rCk7cgVjK6dxd5DmgvSx
lmF3DRQsEuzgkVmm1GJ4gU13XFC7sRrhBwqfQFPMvLwIkWHfaYMh+3H2Nifgxokv
uhHX2s8s+k45/UVY9EdfJhnuedhAxAi/C1+kiiqoIWYCeIjqB1lWxHNMzOoXNv82
hxdgWiL2M8oxg9BefRXmSFf+6FOYM/2PzxCryqPWzz+Q6qO/srob12ujz0Z2LMZP
1IK9EBc0gxfFAQJYHkISN2ekM17Y9JfBkLriPMqQvQKCAQA6Bd94XW2v55Aq/tYx
KtnB84dtuevtJqNaOY+ae7pgcKqCeV+g2Rt5Y8C/Q/ZcV5juwKgIvUe5SGVSomoA
rTtrfmQk9xJXKqC5WC+BWkl/ZG8ua7eJ8h6b1aVP4VaL0a8O5px4D3uKlUBl9uNf
z16yAITu81o1Xn0yWBxewDTZOL6oQT2ERDbRqhvtQ9SLiwJ+Dz8S5qOEZcE7RSc2
j4fWRE4MnkAHgX/OdxscbqC5m0hqsilxJRYBowuZjBOh052lgXJH3c67ActJ5Eb7
vchs3uIlOGqn2jjw6nncLOPNF7KMi1zmvnpxPrzik4YWrnjJV1eSqYLJF/yPdlGN
GJSVAoIBAQCoPoF3F3DCpCGb7LSkCpymYjOskCS+6UW2xiP2vEvqFj8U15cMIqWo
3azMtgJGcOfn8N8z4RqdVzNQmp5a1gXLiqRYDqKQd10RWGu3gU/ajEAqkIPe1Pbq
9D7RkVeXBSug4lS68c2JSYUMN9FTU6ZZLtauKFIcV2hx71tdqgaDCmg0mF4SiCiz
R11Gl2mxLqVDbXYX2U/iDCjxDK45684io97QbZLTdIkWQZ0YLnoMX4L+GfwoY0iY
xNY4B6pmx07oyJamtc9BCuuZ7RQTMgksPYaVRJPe4K0Dq2MLtmPjU0ne1rz6Y2Rk
4uUettWcr3q6sLhVqcg4kwASLPzKefy9AoIBAGLBkCIAQXIJ88wGbG9h03jqrqnB
firMClWg+BT0S/7soYndNvAfvEYN8aDepbG7ztDoS/sTlDFmjdJBi+6pzb5T9NhR
icmj4+H+Zhh63wTvBRan+/dV+OaskOB0YAsd5IbNovtdOaLKOrJzpcxHhYkOyW+P
/yVQMIPN9fsTVAP0NDWVRSvqK+Itp2If0E4AixyNC54qRNZnQiDB4NSuRsMFFW6B
04G5zkVHzPyE/7D52wc2Xf/7ngshFJgm6gw1+O754R8pmigXX1ULGp5vh2xO3MfM
gahtpKcEKKLNEyA8uL1U/w6slA7J3jg8ZPw/oM+gUUr4CYcxh7AABhOZLgk=
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
  name           = "acctest-kce-231016033404920036"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa231016033404920036"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231016033404920036"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-10-15T03:34:04Z"
  expiry = "2023-10-18T03:34:04Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231016033404920036"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
