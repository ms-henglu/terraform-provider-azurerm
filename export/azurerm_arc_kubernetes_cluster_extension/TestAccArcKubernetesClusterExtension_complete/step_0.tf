
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032643075048"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032643075048"
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
  name                = "acctestpip-230630032643075048"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032643075048"
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
  name                            = "acctestVM-230630032643075048"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1549!"
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
  name                         = "acctest-akcc-230630032643075048"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5uQUS4/VNupmrtfy+Igq3693m9wXXKABJEmFFE/io7c/lccBYbdR9TcqAOi892N9lj+vq+IlnctEw5qebKnntzhYXTDR2Ue067Gy25FC0JdkmTK3dFRr9/MryO0zKXXDOYJIVcOuhrbe8qOjJklZ/tnCiqXsp91G5/+IDkQ06EkSUdgOtHoI1UiIDcLUcMrAdUmBi4YdimT6u9o/nWxt0AobabgsONONOQX82KdTiXJaguR8NbhrY81aPWGupbmOuQsLj3Cy/QePus9FBScSkhG7KVGR4SQJfmTlgnoZVkvYnrVloiv8MWBSn10x+X+8IIAZrQjPOZ2a+JKzPYAM2bl5ox/qtsEEWI6u7eJE5/jOV0hHWcWWH+uT2ksNOBQ3C/Un338ytFCq1M/Fx8ZN+UJWTqmQxCtCJOsfUn6QtrDU9m+yVyIXNzJ1yTwB0Ana0Nth7wpGsthVSd8PvUZLfYxDi92mun+j7kytZfV/aJgw0ImRPzYZseA1s4Rm6b334No2nbsRU4T0JVcUpsHokfLPwFa36m2J40LmJ95Sri2d6vkyerillYFRszTaYKqhScFUFp6arDwkI1+ClAXQH1XXlfqgMo6li1PBRzDzjOFIIuwC423K38GJlesBUTNF03SM6hQOGEAW2yfeUAhqDHCoD2INuZvst42LbTs/158CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1549!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032643075048"
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
MIIJKQIBAAKCAgEA5uQUS4/VNupmrtfy+Igq3693m9wXXKABJEmFFE/io7c/lccB
YbdR9TcqAOi892N9lj+vq+IlnctEw5qebKnntzhYXTDR2Ue067Gy25FC0JdkmTK3
dFRr9/MryO0zKXXDOYJIVcOuhrbe8qOjJklZ/tnCiqXsp91G5/+IDkQ06EkSUdgO
tHoI1UiIDcLUcMrAdUmBi4YdimT6u9o/nWxt0AobabgsONONOQX82KdTiXJaguR8
NbhrY81aPWGupbmOuQsLj3Cy/QePus9FBScSkhG7KVGR4SQJfmTlgnoZVkvYnrVl
oiv8MWBSn10x+X+8IIAZrQjPOZ2a+JKzPYAM2bl5ox/qtsEEWI6u7eJE5/jOV0hH
WcWWH+uT2ksNOBQ3C/Un338ytFCq1M/Fx8ZN+UJWTqmQxCtCJOsfUn6QtrDU9m+y
VyIXNzJ1yTwB0Ana0Nth7wpGsthVSd8PvUZLfYxDi92mun+j7kytZfV/aJgw0ImR
PzYZseA1s4Rm6b334No2nbsRU4T0JVcUpsHokfLPwFa36m2J40LmJ95Sri2d6vky
erillYFRszTaYKqhScFUFp6arDwkI1+ClAXQH1XXlfqgMo6li1PBRzDzjOFIIuwC
423K38GJlesBUTNF03SM6hQOGEAW2yfeUAhqDHCoD2INuZvst42LbTs/158CAwEA
AQKCAgEAsLaZredsyXYHlwQiqwMUxVS3l6uQmczAcvRuDUjC7oh++vRv40j6SlKp
LD70+ebEpO0jV8ti/O0pOQgq/oHfngRa5SBLTCAsoUPE33XDDIECdpoxfLBsXj5Y
IZUh1jaSb35+PF3jQqnN4ylI4jG71mj2E0XA5g1eiouxpzGeyLW8drWFM64++nZj
4xxdmeIkAOB8bLv9+gElQgddLvBg75v8tSJHfkqzyJQDnBIcxpKmIY4cXsVCNAVk
bpxHngFx8cA5XdRkuXJDGDgw3Cu2c+NsOsh6fTUmqv0wB3fJ0pmENpwhKEi/4U6W
jfA3In0YEEva2utmJvOwO1WUJ5rMuZZ+q/sI3KcAciJB/BBlvgwvjlz4+eDYd6v3
/2Q2B414yoZFVUyAso4FT1RdoSxfMo92TWs+PebG8DW9AdAeC1lCrNB1El+1pC+1
RbmlrdQgfEvjtO7ioYuc4jmOZnDY14ytpy+45802jHMaItiLH/t8bwsffdc8rYWg
G7keUsaIcmDTHNuC5jsAAe9g71VGRaa9hmXKryqUy1csiNKDAhLdmY8Gge9astI0
+oUUPNIQWqlUPmmNLP6ozVsg3n5hTW45y1vWb43toK8j3XVmltQ15N5PPy/82k5+
dyhBZ6Gkx68lX0VZ2Wv4h/YLTnfx039nTHm1/tqHMmc2W3xsYrECggEBAPqkGjEA
VtFMryfOUhdC5I/w/FboTXZqsB9TvCnrkfqhE+BY8apszISWQnR15O4osEdmzler
Zg7tie4F5hrQ4FaIT1ysZr3/LbxTyjKGCHKG+ih2ItbUM6TREZtZmI3LCMiXT34f
4GpMn13RaJk0Fs0XkKzivvq1J7pujU9y0E+5wP9BhCzOfAoQanW/qOfiW/JyWj6y
ijy79hrz8WEYD5BMGEfMh/CGhHsnefsKrhTthfuaIsP7a12uiZaDnCnYATA50ajF
NvRKjNSC06Dk3ALCL13nufNu0XGw+r2YWyGzV+2NrU2sR/2f18K+u0a70KbyYXRn
fsjX3bZrTtvgUNcCggEBAOvT362uEKpTeVn0Ox2NWA5XU9NUKZnHqRSRRVnPz6MQ
dvShOMvQ43NBSgXJ0+aFZP8dweADHePL/i1O9Dsfw/Ee7XWwmte8K2zd+y8hyE6A
DOthBFBbc38+ePUn+6jcxWVqU5Ff9BDowI9gAQq/D2PjWIkyUO/O8GzyYFupB02C
1PNz+JEdh4UQtbkyVVgyUr2d6OWQkOOzstHywP1tJNgluBv9eXIFyq81OomF8tmT
i8ke8TIrTZvcf2ythi/TP8STwBNGJlhc3oNNwnnR7JrSuhxzHN2H3sn3FnCg/v6w
9efph2ilSAp6DjJev3F2kIEVhhKrcBcEeSmiXQCFLnkCggEBAJm59OaBEr6kjfmY
LfleadlvMRYMvRYYMZXFQe9kMNDL4ukDJJYmzPm1P2U2ugbopdXlVEGpOpuFTcfT
jmJ8Ilxwllx80TdPP7n2mlmKo7u61cvjSVMCK/q20Fm8BjlRgj2lsHfnDTmlbUmZ
mtH8hM+d2HpxSDl0yr0p+Tn1bZa4k4r7oBnrO2Dg2KsHto0i5Mo7IOa7ktXVYwj8
/dtTaphSU8IVzHrVxoPSnpo+3q6vUDIVQ6V4m02GM5VBe5KejXwKunENJLuIzf+5
jhtswxReDbdG3WJVYdidd+y5eYud+BwXfWfadv00AJ3NZgfoQf1jRCqlH7oHzFCK
WH+7gVkCggEAL1j8obw+8FOOG7djXw2PzmFOHTHaoFtr4QtBp0SH5a9akscDxjgM
UombOQpKlw/VNTteP4GgsKm2QJaHho9cIb8Z4fUxQXswJM10rwPTWZ9v+Joj6ZZS
3AtI8b+zUTXyE+iDGr7vG63/a0nVK7ksd9ufXPxTL7KWpukK25xWMQPBiZeRImGR
Ye/27FXkuK5x2kwoBF9AF9duYaShhsAxE4yPKF990JzFEuRW+mGAXpq3CAxEVNRI
4rAkjUdRl6yMMwWPHM+Kx1bt/eLQ1vCE1pjUcP3Tn861tkr7oGVSjQQuev9yBlqY
2jGjRA2t1jP900zk/D6bZKOrR+anUYFr0QKCAQA/+xXUOgUuylO+KyRVmz36D24J
LzuICBIu5/t9jPM1yNlc3KZ7aqAPsSPSRPilFP+GOLVuUSxuZcIJnjXyjBgEIPtP
PXDg26L63lUowc0TWVyba+sREExwLXVQKnUHlLWzftItmXpY8riKzoiz0OJpAnUS
n3Qd+JwGnXu8Rf3D/PDOyaptMYyjazpvFO0nPg9axEA86W6m2j7rfY3BQVhhxPrK
x+j8exF8xd17nSQpBwyvyu0Tx+Cgi5ogvVoYjiR3rXJbYD3zZgAUKGsXo7ydzdek
Xf2wdeQDnOj0dcUm1pTrGEMeW/zXcxiTyZ3mLSsu3ihVhDSaElTNxbOLourm
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
  name              = "acctest-kce-230630032643075048"
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
