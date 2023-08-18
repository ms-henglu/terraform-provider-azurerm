
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023512805610"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023512805610"
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
  name                = "acctestpip-230818023512805610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023512805610"
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
  name                            = "acctestVM-230818023512805610"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4659!"
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
  name                         = "acctest-akcc-230818023512805610"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuOtflvvFPbEvyuLmkhDICkCWibhLKcLav6RloYLY5nR9b8qNUfwmk7Vleao9WFuebWq6XdsatpyvZh60ni1PWNoD3CenLzwm48EXjIJ1CDLS/TW3y6vEbvBvhYQUDYjdVK+6qaPBaYluiaY+3ld76I8Vt8PZO3tX6nCTFGvCSmWw1Gn7rIVIIkMFyuVIdXu0JskV2Utdhh0iRZgG6trOJG7j/Fvca0yQgDmm+o6EHhp+xTHVSSB6N1LhcVM4Z4znTIaznihdVMRX6W3kZl0TYmGtoxXnIdg0JowqxNfO3bxxqUdghkzq3waZmDN1r23axaDHKAcWq9rET4D5zsw5XB6Ii0zO/dUSZb97MM0b4ZVVfRHoN2Z+tZuatMgSo8RY0YoLoVSPL+NsPRJIsS9ed1HapnevoUbyPZirMbcsuVcflxdbXx8QtI7YNd5u/Xu9xsANdBYurDKzkwVqqGix2E9jmycQ5NQMraxCF11S2AayfcaukL0ube4o3LkdIPxYjIPcHmdI/IXg6WCKUrVL0gVOTV9UigEvmFlsVviAeaBf3+8VFAufCfSjYo/Yzc1SASl9HIFdADvd/lWLB2dILHu/+B71LFH/ODl3bSnDuzc9i5fvefSXhuMpUjRZnLvtT7AYdDW8vRsVNA94dHBTXR2vjKc2jVqeES3e4IHFITUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4659!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023512805610"
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
MIIJKwIBAAKCAgEAuOtflvvFPbEvyuLmkhDICkCWibhLKcLav6RloYLY5nR9b8qN
Ufwmk7Vleao9WFuebWq6XdsatpyvZh60ni1PWNoD3CenLzwm48EXjIJ1CDLS/TW3
y6vEbvBvhYQUDYjdVK+6qaPBaYluiaY+3ld76I8Vt8PZO3tX6nCTFGvCSmWw1Gn7
rIVIIkMFyuVIdXu0JskV2Utdhh0iRZgG6trOJG7j/Fvca0yQgDmm+o6EHhp+xTHV
SSB6N1LhcVM4Z4znTIaznihdVMRX6W3kZl0TYmGtoxXnIdg0JowqxNfO3bxxqUdg
hkzq3waZmDN1r23axaDHKAcWq9rET4D5zsw5XB6Ii0zO/dUSZb97MM0b4ZVVfRHo
N2Z+tZuatMgSo8RY0YoLoVSPL+NsPRJIsS9ed1HapnevoUbyPZirMbcsuVcflxdb
Xx8QtI7YNd5u/Xu9xsANdBYurDKzkwVqqGix2E9jmycQ5NQMraxCF11S2Aayfcau
kL0ube4o3LkdIPxYjIPcHmdI/IXg6WCKUrVL0gVOTV9UigEvmFlsVviAeaBf3+8V
FAufCfSjYo/Yzc1SASl9HIFdADvd/lWLB2dILHu/+B71LFH/ODl3bSnDuzc9i5fv
efSXhuMpUjRZnLvtT7AYdDW8vRsVNA94dHBTXR2vjKc2jVqeES3e4IHFITUCAwEA
AQKCAgEAg1zRfxRDvduNM/eUC9dYA9B2IEeHPZdqhhFnESE+rBe8tBmT4tXZIb0O
5SsGgSo0lU3oLpxjka4k+8p8TJGreFcHvvF8VpXImqqk6/AQ604PjEkI0+qllJnA
33xAMo0zjeF4HOJzl2FF4Qr0Rkang0GCEBVU0GiCv8xQ74TNdMRgpcTUQG4+G/i4
uLXAj5TdGWBn4QEk4wz3N7ET2Oqu3jrYQoGPR7oQPMa30+5B9JCl1bfc6CHmMD70
X+jafNUfysE1//h0tK72NKEYS497Ibx5+QyqMOTBx1BzYXpdPi+MHtDRxRYHE4BA
xFpqE8FaVGIumETQ2iyCoGfjDgEODSfpstihlpDM4e7kXNYtcHwKCRxnZNpr5gnX
ftNDpwuN6Yi6aRh9juSxNZNe3M88yjEK8eF2AnZJ5CBiquVG5J8DywB4Oe6aSF1r
4ehZA/fH/v3C9ukYNiErBpui744HS0g3cix57hJz4o8FhaHZCamAxaQjr6rDEr9Y
00obMBBlpVK1QetJ8lE435BOdlzw2ZdUtICOQhfMvE1FGeZK6h5B4xkcs45CuLi6
RbqDp3+31kFFuf04Y0AqU5J8HWJSgWPtNk/cyMozxaz90Rbn9ULkuilmaZPe1Rb6
2Cwo34bdGYYTZrKxhITDtO5I4XhGTyAeIQZdUE8gCz2i4nLOBwECggEBAMQnxyyj
bfsPW5dLAXTuDJIZwEOEdkuwD83cTMWVeVi7JMPP2zt1ecKhuPFLL3bz8b3KvNBE
ksHgbw5E9UT1aRPYj2WgP9yrqBJs6+tspIX3iNZ5yOlu/CUpNHAXjkkBjoveqhxy
joNPRP0cJWRZuJlmZIhH5JymKJrHYR5PyxPgWS/FCxbiK1XBz7WLCCGchLcm1xeM
dox4Ig+3NbBgEHYtIosoPvRfNWn5EwOsL9IHeIBLKs+oRzAOZEQKhezC6wa1A2SJ
vNUopZmqxHb+4GKE3ALeJJezxzY/wzs2EgBDsU+D91NhuwPvg8n2cOynsN/+UB2z
YtP1jx0AoZAGLZECggEBAPFWChQ5d5mXbM5N0E/f2FkFpTxzMBqEY9TAcrply1cc
ff+Yx90a/ZPYsMDp4txegTD35mshZVUeVKdZ94OastV/gI4w9UyfCIdOJi8gogXr
PoTDTmCjzWL8G1+22pjMrS8U+Uo/4GXjaSbuwZCi1skRrz6oX199LVDajQfW+r2z
qmKz391eUXes/F02MrzR3T1b/K9c5ta1/OLqx8mQE8YTrOZKauHxYS5Kr1TfB5VI
K2Vc0QPup7YFjprAqnxkBdZbP1n0WdQAV4qZWuuCph199BAmDvG6SGiS/aK29Eng
//7lI6kwc7+EkNRmR4Q+YgQ2Y1VqUay6y399zBlbN2UCggEBAIW25ARe6AMD5hjN
TZHrEHCr0y9zZbyUqUFY0pDCIzVEZXyB/d2baEQwQEVkTlfVVU5enLWQeUZmeu4M
PfIjJN0dfCr3wXDpJypgS7Zxmfmk0wf5fub5/DJM020x8ZF82TIpuGaqBNIoQEwW
Wrr8mmUfsppf/8x1TCqujVq/ZB0Ji2KP/M49oPLVqoUD4Kgg7St485ke7FU3M2jp
KFUyNyaIAAtChR/Kozu5SafwQaz34MH7+5QRD24H8XucfMz31oT88fIgHrRj//cv
vLutZUJjdSMTUXiEWeF2N9zuL/k0K/ObbwbNEVJOfNU5BKOecGlREEYe2djJhSRt
ILVwMLECggEBALvsG30UIqVe3ELpJMSNsZHga4Jez55WaMZJ9QxgJ651aUeWWEs7
sSlnGnudpCGlFURkRPA22QkmzRRjYfEAjTDiT+BpDxnS3Hk/yUv5RTEGtW/8BRQL
eOsTFN27LQy+lDyNQHEovDuakU7Xq7JMmqOHOca4pUtd1eOXyynHpQgC1zJ0jmV6
BEYEVZ7fjTKq2HPnJSQIW1fl7j1kRJ4Xqs4alA/e8sttghbh4RVddjIwOFp9o+RD
+iQqv5iRXi/uUv1PoE0TkL8cZQ5vy/SHj4J3iYzplcl1HN0RWJ9Th3Xf1ndNRi+A
oyEGwSAjZJz9VqWhFEh2uZKfAccM1dkIxmECggEBALB+3B5+LJ3u+4Fkwbd8IQzS
CunDrbxTpqizTYZ0okVJSlup6nmDpyvtZjZ6xxvEosX4/tQx1dkqb5BGFKCgllnX
5cj5UlmO0COK+8QSmXiGZZRs6mcgnyxaMFPrPBci5SSeiBxRw/SVD+bb5x5bzPkD
f6vQ2M3NGQQeC8uforA41LGBIK93eZN4aZKmtkFXDMPuKW25LbhARp+V+oWAAsci
7/HBOVb71CajxYGrGQ1Ux1QejCFKyt7nPOjAvVdCRnkEPPZ6opxOVKioVeWiNgEw
/wjH3Zb2ByIbLABAAwqmxnfcaLprBE/aKi/g0eBTc3RcGuVtibXgM6n8bOg5L0I=
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
  name              = "acctest-kce-230818023512805610"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
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
