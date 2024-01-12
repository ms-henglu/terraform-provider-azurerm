
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223941294298"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223941294298"
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
  name                = "acctestpip-240112223941294298"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223941294298"
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
  name                            = "acctestVM-240112223941294298"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5946!"
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
  name                         = "acctest-akcc-240112223941294298"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3RIrlDM/XljKko4X3mcgtQH3GWJ1ohqeiJsGhwU4e9nqO5+KvGAtUqQzruq3PQW5su8yCClKPxGF7VGlJmLr4tjgRXyjuh/5LVewKYbocAK+8gEiTtmok6Cdw5IC8AWfOhF9+3DMA5ZGiPzUHBPRArGJD3MXE4im2Wkjrd6v9hveZ6Pxtwi9T42V84d8QMpklTusoiNuSGSqLTy+rH+r2SaFYAi5HcVIYU0L/5NVzwXfNgbB1q4uHqVIJTJRk6B5AiXlGX6qGkldKi980wzHY6Ai63bb7BcxTzbIF20gvhqzieIJZ9XehfrRfK1GA1ei555RqqcEHPLihjeW4Bva1qcBMhz7/DoSqqddM9JFgKDvsg8+WCn4zj/9U8YPV99KLdsrlgv4793cGOBzjCYD4B7HGakXsSQVSS5tQDwj+KJ0MhgHVfKca61Y6G2HysmQpyzYypu8lPDzRqJWrs1iVDcA4o2wnvz4CYq4SPEB7AIZufWaxH7/qJJ9I/txj6qZp7PVEDD7BE4M/p54RNLpK/p5/a4lEIB2M8Fa89DJAwFN841p3p6i4XGhi+3DEdj+wN6ESJyKkAPQSOZGKw16ADgcW8+5nTPJuKqTqFBg4moTiNOkPVshkQbz9sRpCKPDnr4tEMf3nggMrJ7YEAWBoThHxRb1GB1XpExSvaOEM0MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5946!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223941294298"
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
MIIJKAIBAAKCAgEA3RIrlDM/XljKko4X3mcgtQH3GWJ1ohqeiJsGhwU4e9nqO5+K
vGAtUqQzruq3PQW5su8yCClKPxGF7VGlJmLr4tjgRXyjuh/5LVewKYbocAK+8gEi
Ttmok6Cdw5IC8AWfOhF9+3DMA5ZGiPzUHBPRArGJD3MXE4im2Wkjrd6v9hveZ6Px
twi9T42V84d8QMpklTusoiNuSGSqLTy+rH+r2SaFYAi5HcVIYU0L/5NVzwXfNgbB
1q4uHqVIJTJRk6B5AiXlGX6qGkldKi980wzHY6Ai63bb7BcxTzbIF20gvhqzieIJ
Z9XehfrRfK1GA1ei555RqqcEHPLihjeW4Bva1qcBMhz7/DoSqqddM9JFgKDvsg8+
WCn4zj/9U8YPV99KLdsrlgv4793cGOBzjCYD4B7HGakXsSQVSS5tQDwj+KJ0MhgH
VfKca61Y6G2HysmQpyzYypu8lPDzRqJWrs1iVDcA4o2wnvz4CYq4SPEB7AIZufWa
xH7/qJJ9I/txj6qZp7PVEDD7BE4M/p54RNLpK/p5/a4lEIB2M8Fa89DJAwFN841p
3p6i4XGhi+3DEdj+wN6ESJyKkAPQSOZGKw16ADgcW8+5nTPJuKqTqFBg4moTiNOk
PVshkQbz9sRpCKPDnr4tEMf3nggMrJ7YEAWBoThHxRb1GB1XpExSvaOEM0MCAwEA
AQKCAgEAgg39eztG7V85FUzot9tdv37/enyVDZ+xYlYpWed1Wk9R4G+0c6v1Hegh
y6aj1A95Ns5HVcvMtRu++WWNze5mLVc/YUG5JHdI5SbwKQ4H0lWbNc36+/5KkUbt
aS+N8Nyt1sCRqAmsy/NtXYu30SjLTlVZd7BShBhhaAfViKU4SYYNqlUlj3Nhw9pc
vB8ZtxgaYjzwC5bie05VWzWgSuT1GVPzJRMcrGnyceOcymdIFPm0XhlNkdl4omjD
77YRjdLbPatDg2Mj+UDtwTKcsaCT8IU15eZP7S2bwalNv5Jgr9YPh29l7yM/vPxY
n4tkY/T7jl1yV/3XipxNLX6okQFyFLupUK5LjsdATE6nh0UGZgvhUHydoTaQIH3H
L+czWyAHPkfGZ1d7d9OjPYz98KtGtY6hHHfZC7GKdndIfCFVkhQ8d3/zMMbbrriA
SqdaiDyMsof3+UcZsiluiJsbusb6DWRxJowkgO9wlvDbJTwVrNBzCIVHc8dpx+TE
OaYTHZUM67KPaP0SqxMF9dfZPxA3mK4URaPt9JbpglfcWSpCgRx0icnomYDzRYse
OTaOSROwTzgjMoq/9CXOBaw+tG+8jAXbS4Fqy0JAdo6GG0sG6f0yTcyjkqe+PiHh
AwycCuz/iomm9r1tbS/rTcY4Et+NEnb9yboQriCpwjpu1WVpXakCggEBAOXJH/ct
f4xtJBxZhmO6W6shCJTpuJcgf7O/ljvFdXuV/4uj+EVdAWzUUBYQWx6p4kio0mAE
6sx4GY3ZNnYScXuBAKV7r6Z2F3FH5JRyci2JqbMs8mDo316baIRtMv8Q1fejQG6m
+G+KCCle9Mnkdg1ZFVWKGBRW+Tn/FvVijlYGrUUxqnvB+HBPPAKWWSdcr3lFvS5o
2WX9n+/GTrIjB774Z6hWTqvmpu/TKuK+HvtDPgnygaq3dQWjuy1ReKnjuFK+PD0o
tTeEZahUSIZQ4oZUb0A6N3Hgj+yPK2LhUaAMib63Q3XLJca7oqjLfx5ym2wuo9My
8+avckhcbxuK+rUCggEBAPZKiLmYWgoWFmVhdZ0JvweeoHYdDH4gVfH8Z/8JH6IO
bYq/BMEWBD1P4qhvQHOhxrd1I/mT1IqAOsOVfwc9oI677LcmkOxkp1Met/u1hAOE
RUSJJKCpq6hRCqcdsZIkciPHt+5mfRmj58EKx0zAHJAPWiudh/3BOU4ewLWvQrf5
6T65awelUKTZxJ2Ma2y3zjXcpArgU3aQti1x+mQ3Z8SfubT5gukVF91CMi/eBYft
9877iEqMw22MzUpwfhqRjFf57ORwssem1q1piCpaOfzbRChdIGOKfsMBaNCPtKud
RPFtQrRenCQtdTmEjDsIjijlLnc4pFBrokY/XBTcGRcCggEAb/BYiBs8BXatnrnm
A/Mm8Oi4u4JYEBce3ru4PgnlP31E7gvEyFWUeiW7leQF35w2xdqoEWqTz2O6XyWv
qDk320huvi7Q1LC2ntK9Aav2/0QOzWBZ+ue22OmwMsLXkvXqpiZ7HuxsHjoJ282M
RkXrVHlPMUqCjHYKFzyzPHr0h+fcxNZ7DKrjkiKnQ0NmzwwR12wnytH9BfhVz4K1
l4YFIfz00kapMIi+Thp6y9Z+VTzeng3rKPUSJtsqNdt4gpqSkoxl4A1Sqmbu9t+I
LRZ+I55CS/GQTQNuWXktU5AcKXGyMJwqWtnJ31RM2xm3JWgDWuIloJ8zve8+Jw4Q
ekRr+QKCAQBHyzJP57lXd1jP9Lj0LgMhlXvw8kbR/VsQTyOBlIdEFjCYYVZhcqmJ
td+8ebGwA1iJ4fu6pP0v4nE+0jVVRwGmmeFHAlb8kdq0wB+hoCf7XnNSpyemLc98
ISOZ024Py8/53h4fwIB3GPBVtW6jUN0CoXcHf8RElC7ANva1/4DTYGY9go9Qi0AW
zeQiiOxHpMzXppmrEflCdqykUrVKwVveVTEtMA6ZIyzxsnouuemi1huGmowAL0hI
huLQ8DnSRNtESfZkIPX8fQXXRwwKTILa0o/rtDncymJpNd/36+wempmeRttK+MlL
QnUJbznxe2z1Ptlsp3Y+eyGymIWfDwnBAoIBAC5lV3e4StW2Ne4xQEuQ1PHvMr0/
3V/TP9YX6OJ45YjssGVnWfy0aj8gLGixTlvubw4XQQRfQWg5a+sYYKN/9afgl8fb
xO1qdgGWIPH7diyJ7zfNUSzu9632lPWw3d03wvbOMLSFvGWzVq5rMC8l84aPWG6D
q0J2HvWmJmoq8JmykYc/kwzZNkPBe5Rm95MymAttNmFm0Zd6AUdHo4jLOznW8exf
RyaV3LTYCbEK1DaN/caTr33lQYpLQV5cj7532n4Af4BzVmNdZxUYsl1Hp00qgYyp
vZBcfzb7sd/YNsxe1nSzkicVxKBs7ZNlL6gnyl4uQIp513jHfqhdnA3DOcY=
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
  name           = "acctest-kce-240112223941294298"
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
  name       = "acctest-fc-240112223941294298"
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
