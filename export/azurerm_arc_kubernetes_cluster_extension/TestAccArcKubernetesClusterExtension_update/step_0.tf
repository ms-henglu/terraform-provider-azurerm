
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003425053109"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003425053109"
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
  name                = "acctestpip-230512003425053109"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003425053109"
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
  name                            = "acctestVM-230512003425053109"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd61!"
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
  name                         = "acctest-akcc-230512003425053109"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6WIRiJ+fd1LhKHHcp6fR4QjqmSfCZjV7yeAuDrklouiplSN3Cbex/VTSqG5+tctCEwdEZoqpX0o/IG30vzkrlrlyhE/zYPMNKQV3ufTYXbyy8QcI69gL1TymqNk4hfb8QeJSUMCb8b9b4BCMaKrGsP6U5TGv3NrDuH1nCPhm1AKwJpHh/RXrGuFFvsGnq2M23Z7Le7dkVFDmAqChq/BFvR1eyt0iaHAU8C2HYkQRRuvkxnDKV+Rlya40DLTja+W/l6Mo1ubpqBUg76dMNxGrNLxnm9fOPiE+u5luc9fShBJvTEUnYCLwCZbLTznkiCIxRfY+CleYBZwTRKyENvMt8NfxiFl8C6VgMHz/5oQvgwLlrfSlt/UHtW1O1jYi2Vb7JUv7JzFSuWrGj5xAgLUHKK8frtmV41LeGEcMsfkh/108kKttUNBmEcswgqmmiSdXG/1q7G4okMoMqWjBm2CowXSXHEVs0bFNzmpZzWzDRS1aSzz0ilx+b6VscgTNNlXum0EvpcaaKbiYjwk0woX7f7w1cjF+pH/U8+iKtWQ4llnqr0DshAZCcSeSLjxeG5np9yHYwBFJLm7HafRwwqKdKGgm6dxhVGQ+W6jmZIV0f9jw9YILNRn0Rg/gEgScOTSlLK6kL2TpHRyI0bFy09t52mFqZ0sewqk8Ab+TtQ+O5EUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd61!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003425053109"
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
MIIJKwIBAAKCAgEA6WIRiJ+fd1LhKHHcp6fR4QjqmSfCZjV7yeAuDrklouiplSN3
Cbex/VTSqG5+tctCEwdEZoqpX0o/IG30vzkrlrlyhE/zYPMNKQV3ufTYXbyy8QcI
69gL1TymqNk4hfb8QeJSUMCb8b9b4BCMaKrGsP6U5TGv3NrDuH1nCPhm1AKwJpHh
/RXrGuFFvsGnq2M23Z7Le7dkVFDmAqChq/BFvR1eyt0iaHAU8C2HYkQRRuvkxnDK
V+Rlya40DLTja+W/l6Mo1ubpqBUg76dMNxGrNLxnm9fOPiE+u5luc9fShBJvTEUn
YCLwCZbLTznkiCIxRfY+CleYBZwTRKyENvMt8NfxiFl8C6VgMHz/5oQvgwLlrfSl
t/UHtW1O1jYi2Vb7JUv7JzFSuWrGj5xAgLUHKK8frtmV41LeGEcMsfkh/108kKtt
UNBmEcswgqmmiSdXG/1q7G4okMoMqWjBm2CowXSXHEVs0bFNzmpZzWzDRS1aSzz0
ilx+b6VscgTNNlXum0EvpcaaKbiYjwk0woX7f7w1cjF+pH/U8+iKtWQ4llnqr0Ds
hAZCcSeSLjxeG5np9yHYwBFJLm7HafRwwqKdKGgm6dxhVGQ+W6jmZIV0f9jw9YIL
NRn0Rg/gEgScOTSlLK6kL2TpHRyI0bFy09t52mFqZ0sewqk8Ab+TtQ+O5EUCAwEA
AQKCAgEAr4pSAd9+RHQUYyVxgLFbzdW1D0m2kMY9u9RhEDX2txglJcYtLSP8Pr3k
TUf/CqI9qq5WpoI5bzEbVjseUg6gWJhYKGkyeIOYLHiuWzJs4+Sg+2X9Mdeo3tTl
zi7Esw7ZIn0myRJ2uVjjtB7+XWPGWy7Bs7qxun7ZpBS+wSKFxYXYFMq5nnE0C13R
5e8nPGQ9ymg8SWvhjQHkX6mOsRLigaJrwE6gKMnVFepI4IKuNBgOVaxUpdNnNFFR
WRVd0bRXbakNeMbqjMCHq3q8etdRXTMxAylJObYrx1NansuAzlJHYKjLOyZMQgoo
FglHeZWuVh8m/wRvlhiU7ZyNPf+fVw4uC2GaUYE5NhWgZdceeIAsFlYdQ0t0GJpt
G405OkFgkSKp4bEjbteVOAccRsa2RT7xcetw62NPY5t48PHa2Oys107wJ12dgkH5
DxfGjkS5XJH1yJcFZgpFQYQlXRhMKyNvtKAX+f/Vk/oskZ1vlvDucPKtGXeHL7ut
1qNPCi/2TB56vYPrUzwaH4LNRP9Cwja8C1YTuaXVlrp5Cy7apXtGuTh3uqC2uS9K
75Ktqso8xbc0ddoal+1CDIwrNrvZJg3qFU68LGwnsJiugAjvMspFXgnYcFSyr7bv
tD2RPQplOy/NCICkYDmyYEhLCWlwuf0waS7JMcLa2dqdm4zGuGkCggEBAP7yA3Zk
amYhjKRQPKJpyiNJVxYgz9H3ppe6Qy/H/a1B5KyD6bgGLvvHemSv70ljHSyPD/4y
nP8Zm8jRTEKIL0Y7JRvqjtc1ZRpayRkvkDYeGAacMas4D4cMsC85xqAw/H8DS8ci
sJclMraoXc4eXTtYph0h9PrAqURg0jaLXsp8M1/sseHHHQ+vyZYa+n3ZMqQyt+ak
tftsU0GHbVN8KWkoEHQ2H5sS6lTr0Vd+bjeiwrcS8Jhm95z8Gqp1dTTu3YnEmbmF
HuvJwr7kov7gChdAQh76V6DCdrWaxdiWJ46fTUORQh89KxlU7XauDHqDvjN9OPyq
+JnH13I8vJMgqhcCggEBAOpZOHbAKHaEzjWSUvVe0CgzM/K+e6z9hyE/qdpdBWyy
n4JQxse5Cjci+y+1+JNdRT4/jv3wmgg4qATkaCkQGjt5bX5gJdT6Smo1iUhkvl2B
bK+YQlBH/Hr6LctyvVziZtkKdf7SREsNAweaphZaw5wvRjSIiUnZPbehfeB8yfQp
pZVCBJeYYS3Up4KtOJbZE/LzIGcrkoEMIaTdLLUbFnt5Fy9sHzhwltbIeoInCVEU
gflxZH8/lGTJS7RXn/HnU3vtnNEOu+SZzGYZ2Wr/NytaWCzoSJXLTUhOBtBKm3s9
JxdbN2dHQKjwg2wj1szrai8D17eQNvmA6pfV7Qm4CgMCggEBAI6Eg+L/J2uIfbKt
F/hC4zjumrxIA2UA6CQRf9WKGwlruIWoCFNTQZiGXqlCoKWJvplWMD6N1K3Whvuv
5M2ci7DbB1efu9IaizY8YgauTBO0pwGq9ykb4bJBKYx848hRGhV2pjnf7o/Pv5XU
cPv0hXHTkKjgfq5eXUFYTqsnJgpTe/S3wIjSYjCOuEYtNrJ7ZI/dumg403KFj9Ul
+7ubwRqDxw7v4qMx48UtPo2Go95+IhNthwnrJaigVdfMaYT5suZ8/OJ0xGBTHYbR
ET0hyQJObagbkjjP/MRwjQESj3JvIyYOYcRM0XcLvuOFUHx8gSsPaXf1q5tr18iI
o3Ir5GkCggEBAJ9wTEYevmjEOjegceiWtTBkhbdleWdcpg8s7Taviv1FGdjjdBp1
/kk894CiYZiBIJcVTwfeJi3pvgZ2D5fAaNiF6MTOTW71SqOwANLMF+guIe/lu1g7
Yb+Zboa4bbVAI5EO2PChxez50VHfGZij7+nXEAC11BH2R1MkACw3On9vxkQiQlWR
SqyPvdfeWl3nGvd0Clum/WnnAwzTnZMp9sXSwL925FbV4woGI7NhM6mCNlurliAs
9Z0MhwEPjLZcGCR8qPBjAdqp+LKOa6msMbDBKrSC5L9lLhM/YstbtyTFmk79tFgD
1i4aVI/CYmXQ1NFf3+f3qi9eUj0zQq4WFFkCggEBAN0mcAbNQSwgG/+yCF3WtOSa
GYyxpxOC+5k7oZnhnb8ei2O3TtVGMI8vbkU+biajPDhx8ZL1ZM5voDXTQqhlhITF
tGccjA7TZxW0EIoepJQF+gh+Y4pnSFA4qz8DJMvzCdFeeq3bjVt+5iM926UnToUg
vJDy2Vj9hbfPrrOLvGizcb7KvarROuHpn6XSpLB3dF2iG3IBcBz3oNUzeZfkekCU
tXiC84AScoCb2c26V1GEO5Wgzt62iRkODVFXhcqYbA2361ZFs60r2gDwARcrcM8P
KMXxUavkkIBJPk2q49RkTf19Llmui2KijtZoCvn4LuAlzY2yjSN1h4nGXzsDBeM=
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
  name              = "acctest-kce-230512003425053109"
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
