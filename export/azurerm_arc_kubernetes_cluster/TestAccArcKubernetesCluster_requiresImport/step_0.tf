
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025434349296"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025434349296"
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
  name                = "acctestpip-230804025434349296"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025434349296"
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
  name                            = "acctestVM-230804025434349296"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2626!"
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
  name                         = "acctest-akcc-230804025434349296"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4WQU1TDJpl4UB6gHJMEf/iz7NsvRN5xM9C2lIcF8i2WKN04J84gRp/yhfVOiidVgsn0zFo457Akw+6jRP8pvfRg5ALLlyDd8zIeNtBNfBcJWbd+zSRycLPvdMZLVDA0NywSa5qQ2CRvmVwJtx+OcoSwVOWwtvM7j0VxqRirQc3L15SGPdoQNpSs/4ucXLfHxlwbdXlvHyyCB8zhirQ5mKPY3c2zqOF8RbAGswiR3yjEOwLFOUUIVTCMLRFCE7iXnnULKyg3DTpZKaVsAFhMNuDkKfy3MF77Ma7AB4WhYqHOaNa/ppk2PbQpik74dUbGf3wANcNQdwufQcMp3FDG3on8N+cIalnMTSeR6bW6+33OPySVC3gCL0zutSF3Gd8NEd1cNcwsVsh0fIE+1G6DuggVgorr0a5K+G3oFqEh9Lbi247rl/h5TJKAjU91UHF7edX+4A+jE+0NMfq1WjjOqbA6qemHA+3zJM19ijzdJqcyXvtIh4nB/PlZSrN07tly95nAtFF2IhKvO2vsOauvprseroLDpxZQuwybn5AcysClXB/3dY1CbbIYOtruBHrS7wCsHfsm7JHj02DZdWbkiums1PEiezb/G1oU4kaNXBdcG/Imu/ffxrp5rWsMNASLDAeijuWajU1MWiqIB1yDoltG5kbYJNL0+Wcrl+zvf+y0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2626!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025434349296"
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
MIIJKgIBAAKCAgEA4WQU1TDJpl4UB6gHJMEf/iz7NsvRN5xM9C2lIcF8i2WKN04J
84gRp/yhfVOiidVgsn0zFo457Akw+6jRP8pvfRg5ALLlyDd8zIeNtBNfBcJWbd+z
SRycLPvdMZLVDA0NywSa5qQ2CRvmVwJtx+OcoSwVOWwtvM7j0VxqRirQc3L15SGP
doQNpSs/4ucXLfHxlwbdXlvHyyCB8zhirQ5mKPY3c2zqOF8RbAGswiR3yjEOwLFO
UUIVTCMLRFCE7iXnnULKyg3DTpZKaVsAFhMNuDkKfy3MF77Ma7AB4WhYqHOaNa/p
pk2PbQpik74dUbGf3wANcNQdwufQcMp3FDG3on8N+cIalnMTSeR6bW6+33OPySVC
3gCL0zutSF3Gd8NEd1cNcwsVsh0fIE+1G6DuggVgorr0a5K+G3oFqEh9Lbi247rl
/h5TJKAjU91UHF7edX+4A+jE+0NMfq1WjjOqbA6qemHA+3zJM19ijzdJqcyXvtIh
4nB/PlZSrN07tly95nAtFF2IhKvO2vsOauvprseroLDpxZQuwybn5AcysClXB/3d
Y1CbbIYOtruBHrS7wCsHfsm7JHj02DZdWbkiums1PEiezb/G1oU4kaNXBdcG/Imu
/ffxrp5rWsMNASLDAeijuWajU1MWiqIB1yDoltG5kbYJNL0+Wcrl+zvf+y0CAwEA
AQKCAgEApKU5WqrzAycCNr2VylGRj1lIgbTNtnPk+xJE6K2wzxtzpgbJ2i5xx2cS
iLyJpWpL4tb2dOmcgkIMmCmwAYtdeeIx8cK9fE6cScRTzVHBPjHCdSzOiP/vTiUG
Zeo+2zjF9KH+jbEzD+BjmPfbPgOVLV9IedP+bUgsv4lk0LEB6PP3kFO9uvOoDBnV
52isVBHDS3HmT8F353httUBhRM2Z7x49T4ImbttznJR0oLWHFBpWDoj3DwDZEe8f
kd3H3TevQ//Ap2z6WPQMk324SGfOw95XPqQzzLzCE4BVP1W8PgGEiudgJO3PcfX+
ILLmNAEvKfWd2+f3faNdbqdX6VaQLzKGdWtIKCL+aFU4r6hLP2EIrDZt/xLPtZa0
a+MnjuI0MvlzQML0hYLPRnEJmBQM8wjyjdEV3xHpDcVMHKQIJrufvn4jd7i6Uuu7
ekwfw8M3cOVpnFdLIDxay/vlXX971UCjxLDt9puLeoKIvUUV8AFQmGv0SIPswGpg
OS5pjqeTiJIyat7LPpI7mv8Ut+6XYJkCs0zaYsegD0ZvzvaeC5Jm9UeytpB4NCzi
V7kC3H6dEhIIb90c8Xhfzy9h16eXRoXb9zgvZ8rGFVc8KeTRcQSDv5X3lGtTyDnK
6SMNYtWHPTwu5Hm9xiFwJFEUwBTj6WqT4AY40Iz16XTzbA2oR/kCggEBAOSr9DAu
Bn30RKyPwRWf/tPSL5j3rZyPf0U3UWJIQkHzDsV2WXYFQlBuYHrIl/XYtitjz5Lm
59m6QTkrD57oJHOuByc1m4qK8Fsqcf52dyfmJvO97dOp4Xj3fJKDRZYsuS9NsVWj
GCZRPxILjbQXVq1IRe0Of6bTidpV87O8r92VXi5/tMBgpY/K1l815zm2EEo7evj5
GBE1/jF8q4klVj+7Wh5FsuYkhbNAx7/EA+Lfd2CYDoAA3KqGww9anogk7vHXskf2
KrAGpqr6w7EtbBDK7OKOdBOG9JkF5v233z6PZ30aZYxMa40sW86AbFCVXUrpDFVF
319Zwcp2Z76KEscCggEBAPxTwVmC9zAL2Ss0tU4ZpkLjfA6FvtGc/jBPACvjwV9K
0HAakbnTa7UCEMHVZaOty3pNz+AGf3pi0Bdpkxxwf7cR8NrR5zOi1rCtQne0OanF
hFN5T+zq+hgLk4nyeQaXgE4k0Am3toTMN8Zwv8tTfnNg6rHSoHEcixxtIJviGILj
ySHdpNLisM3TVDd84x5GkxOeDCkU3Cw2JwFhZTnpGxFeSwdzrbQrIvx6o7/S2Y11
kYJUIrB6ePlG6P+FK18c4kIti8bvlgNS+LxHBG4uqQD/hIbHrInSF/zCct9nTaj8
AgMtLZroWsGoJOqUPpUODKuWO0CRPvDr+IyYrmyCzmsCggEAU6vHkcmFfpjed/Wx
xOPiLkd+Ow6Fa//lpcHz+W5PMCprgT0oxtJtzVhV3ReA4ugE4COJVEtBEp3gN7bV
5GM0008eNu6alzr3b6Q8Scu3FdZU8mLQnt5OLiEAZ+u4jpaWvARFmvwuXfbkiQnJ
M9hGUulbDL59XuGQU1+X6HBmOUHqUEFSNgInElI51mS20psXotHY0Tjz4XhMJndj
nK8YvAElnGYMa8F5WnmdnUFv2pfB6oo45AVsuMjOntOdpls9QyiVh1c/j2EfovhW
moHwRMS7oLpXJr3+ye8q8jNRcGawi0oZVhiwUdulTA4Zk/LTTBGx/ZGvhgglrJte
oo2LCQKCAQEAm4jRHOjij4YuJjjGLU8YMhDhLl54weJguMxpkaRBVQjbtM5b10yg
DqIoTCLLFPqS+1+tbCz1NS5lkJjuKlCaGPGBIpDST/znE16pIvo/tQtgRsf3YVVy
NZIlLpn8yfhnCUQdzG+mnPL4ymRDhQSBZINwB46KgU6T3UDTIeNbMotQNoTWDXvY
efby6YUcxlPAYw4/9q66DLKQloQ/jlPG8IzL+NrwTqdsWG8MMri4iz7WI5zTCS9l
FFsGUkL2+hjmyt4iU8zpDkF9uyiXbYdre4cFXMMF8qpDSPVfM6AMucYlQ2n8u4jQ
MKEBqGsarGxNmRLwkRs2zfDWc2vF0HNM4wKCAQEAgGDhUFmJeG2XoEMHZuLbTUgr
GUicqSFgrY/wTRI0re8+EUXZw8WgvaIehw1t5fXugC4pLe2DjmbCWu8glDeq5Y3G
0fjDI1OiFBuafcLpcQgJ3LFmkpK2flphJVh/+lrvGL8sWch+mZXYHIJKFIz5TYF6
4NfdWmmma0mKGDmZec5XBpJl2uFn8nspN6T4A4JsqD4pSVC9H1/1WVdG5tqMRh3A
099J3uwbxXZcJ4Q2pyZSNAwvP3/alnQ4iWuNifU+vlbrQd3bhOx84vDlS2PgcfuL
cE/kEXxcN9vKWC+kYXklzx3ttzL9IJpLYbtlgaghlfbVenw00mtT2L7UA1PrXw==
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
