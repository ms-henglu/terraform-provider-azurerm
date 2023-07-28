
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025103955334"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025103955334"
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
  name                = "acctestpip-230728025103955334"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025103955334"
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
  name                            = "acctestVM-230728025103955334"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1990!"
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
  name                         = "acctest-akcc-230728025103955334"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyXl7StqjPBe9dPgAStQtUo+kWmVAOMKt4Yqk7z+kC39VkZIQO5za4ZheNr1drckISuHsJRanAAw8c2Oh6BFhJd7AO/jx40Tsno5VA/3u5022A8OeeJt57+HcclJ4MRnSju7wkm0YlYOOWpREGB24uPpFWOZUXNCUqlnHEmgjw8ps2X6N3tnxyPw+5LqNmu8rOPZXDJxH4JiN6Zh+FD+6KjptwrDuBTQA+LqunEhTM/NAnHBmabDx5G15Sezt2L/Dm+aark9Mffu9Lv81w16hnXBXC5HWgC2Yju4WfK+o2v1d+XJf9isY3SyLK19HCiBhrEkRRUbKSqTF9K1i303VzMzdMVADkoAy8/CaBVMcly4T+tsQpUskCsQ7LeqxDxtZz8pb1uRe4+KJEA+7w/A2bBCEhS/BshPx1cRWCflwz5AXpCbhh9pt/mIaG6lKXkhIFgSYfVm3QllXUPH0p6t8tmQGS0b5+W5kOlcg258VbuRNAJ4Fx7R6dZSf3HVX+eF81G4mIv0t1WKRkvWoW64skeiNH+TpLYDNtQj05sg9rcyjblYBhKcivFz4Q49yknPKix+Z06iAiEbyOr2ieZhuaI4gqQ4kc0u8HzPOqqR5ZiThHgFquP86EMZXKbGRb//k3WyIwsJX3IE7LKSbwL/YkeyzFS5/oO+k07EXeRGpWsUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1990!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025103955334"
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
MIIJKQIBAAKCAgEAyXl7StqjPBe9dPgAStQtUo+kWmVAOMKt4Yqk7z+kC39VkZIQ
O5za4ZheNr1drckISuHsJRanAAw8c2Oh6BFhJd7AO/jx40Tsno5VA/3u5022A8Oe
eJt57+HcclJ4MRnSju7wkm0YlYOOWpREGB24uPpFWOZUXNCUqlnHEmgjw8ps2X6N
3tnxyPw+5LqNmu8rOPZXDJxH4JiN6Zh+FD+6KjptwrDuBTQA+LqunEhTM/NAnHBm
abDx5G15Sezt2L/Dm+aark9Mffu9Lv81w16hnXBXC5HWgC2Yju4WfK+o2v1d+XJf
9isY3SyLK19HCiBhrEkRRUbKSqTF9K1i303VzMzdMVADkoAy8/CaBVMcly4T+tsQ
pUskCsQ7LeqxDxtZz8pb1uRe4+KJEA+7w/A2bBCEhS/BshPx1cRWCflwz5AXpCbh
h9pt/mIaG6lKXkhIFgSYfVm3QllXUPH0p6t8tmQGS0b5+W5kOlcg258VbuRNAJ4F
x7R6dZSf3HVX+eF81G4mIv0t1WKRkvWoW64skeiNH+TpLYDNtQj05sg9rcyjblYB
hKcivFz4Q49yknPKix+Z06iAiEbyOr2ieZhuaI4gqQ4kc0u8HzPOqqR5ZiThHgFq
uP86EMZXKbGRb//k3WyIwsJX3IE7LKSbwL/YkeyzFS5/oO+k07EXeRGpWsUCAwEA
AQKCAgAK2VDLShSqIrkf+E7DuMMsA/IcsAESTWFhmL6i53Fk8RlhelUHcL3UkgjY
t7+4oO+iYKH/qUWa2g3TRNUuEumBSYpecFxOGaMIMq/fRCg+KlAXycvZwL2DLk1Z
lplEQ5iz+6fWqqs9OdVLiVpVVhxhUZC0Zcq7KLwopCb1Fch/PYI4//iRvHipkvOs
C2OeqSxRp+ouEqhILs7Nelmnq3rR1U2dwzs96nv26M6IOdjJHlsnUWIiZNXRsBds
5KY2GrVkyrkfk8ORsSGRy0pQ1+KqAKefRt4fDtV9NNLfKfJUwHnz+bWzIsT2+/QO
hNXldLLtvQ2CBnrUJCVItKFzVtShVxCzSt2E1POaV6JCNgpMM7xCd0TFf0/9hHxi
ubni8QpnMILo6M5HjB5N2u4YfvKTHRm35KFJTm+wM7Uu3jFqw6rm3cLhR8nF1VBm
XGDaR8UAQzdYtaHyoS6f2iHjH0xNvtJVoTtWPzittEQZ2jql76nFKkDRrpNYxUxj
NV97VcSrl5pbuv1K3ct1KQmwCfsVBg1lhNaT5Yic9GviutF9X0LSiRzPKivRyocu
GntoMo3B8T6cNA+snGyR/u79f1puuAzXIT/kQLnhdSsXC4+q7OU2jZDqT4lXAx3R
rdhSrp1oaTsyWbof543I71fGgalB3qBZL7lY/Vgd5ql4PbCiQQKCAQEA8gBx9XQT
lFA5DhTb/6OSYFcZM3iuNDjo4TSdPTby5PeWXkYEysljp9UDNfms+ELa1RYZSmX+
M+PIToYBnHlkdJsG65OnHTL2v+GK5XFGXbQwjDIeeIMgNyHZ4lTdD5m2eb9HkI+9
QwMBk612Tm/UOiK4Q1+x6S2CFD2QgJuusUZg0Z/GYWj8fyctRKY7PoGA6tkbvcmx
B1I0hCjzYN6eYJcoY95w01XrqHl/lI/3VFfBRDiprnXUtk5UjhEZvnMlyVWJZA/V
1CwEQulcA2rKX3oEUC7OU6a3XQNyHLq8utPJx2Cr/czCI8ih2Pa6wSeFZ20WtWV7
CjmzAQEH/nXKNQKCAQEA1SDpK1l5X8aikPCI14jQt1yIBvgHCunpV5t6ZjJRZA9d
aL25dNPvC1gkQ77LYHqivQDPsCwMGy1FlC4BTJ+37ElJ1UGdhFqc6xvKO/Y1GwPm
CO525H4t8tIUkSFVJnuybnFYnjA9SiSVCmkopWl0fDHpd707DU/BVAypHfY0B4Qw
tUPjp/RMzcZPmlBSOVNc7rqmDJDQ1SNmnmpfATdwSI+WsIjCzLEt9/YNDdqmTBCa
fKwjwxBiKnz8ffyPV2lNLgLSnlPDN20gc1vTMDPupUG1dKCvqTUBUAWtTgmoruYO
vQ0iPCFdIHZZ9zDSh/UzHwvUP5w8eqEUvAe5Bl7gUQKCAQEA2iAal3HTwAf7FT0p
+qa15g47kdBBvKJbDbo9zBI+JrEfIMQdx6Z0I691IG52QKMJ2az8iLmbwaubPWO+
CgrEx/F/8FB6/W+VRuiFKD/Me+NRKtx16IvQOsFRQZbaVhhniB8n4x4cKk2IW1Kr
YxGbCfeHfHrBwnoZWCMRn0oz0GeuFuPbjKtzgyyNueXXWoSh7YxZW9xyqzWmTkUW
8YZW3JsCddnmeiZkrcstenu1I5mhgttL3gso+lVqE09IlAf31Bw8JSu8wWwXPzRV
kmLsG9jAEIHPyUho1/amIU0TlZYVtpblD3NCvbw2XXguZrE3pjyGjmP03geZ19rV
GL+UzQKCAQB9BkJiIKm3yoFg/wl3TpYJimltlSAkgdVVhCqIOupOBUlpgSqC4zRu
djVH3GvX2/kNYKV1FlG/u43+gAJZHbS6EsASLtylYLZ+oR3AkQzUHTRbdvAd1/tC
X4SbIm+eFKA2c51lpqy9iro3kjq61iL0HB92E3bJt0iU8pxerCgXZK9iFkI9K23G
pJfb0VR6tnFkxe9Unbsz3QF82q+Cui/PERR32LJVe3aY6Cj+QI6fPnoxupV7/2dm
v00q5vZ7c5VH8XX2VPLG1+haY7p+o2hSXzqAAScq3qI3fC0PA1GF0AVDV6oGlhfY
TDU4cdZ+1RM5GipXamJ8GXRdXTZoC04RAoIBAQCqNKWmS4PwzzyEWjRD95MHQw2g
+eIh/SIFYnUqmkj0wM90CxYTBUQWd0I4f01AHfRXj7qWnTjUdRKfQ2RWoijn92+o
ZY16caqf8Ek0lsyHxg2bDSogAhFPPO5C00/uN4pVLJi4IueVjn9XJBmxDZpOeBms
k/ylxM0BswFgC06GaNMWcClK2FbRrHVcrxr+nmueEsSM255jMxGuET6zUJ2M/SEU
x4yPBFAlTfcvZtxv3+l3EnDNW2VGy8KgZYr0+BwdJiUsLKU8i93ryTKEL0+g+75U
CeA8/VjzCvdatGxsoxNwHw8DxqBi5FmvB+FNY1vD9WtqpKcYvUYwW/bTJ7VJ
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
  name           = "acctest-kce-230728025103955334"
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
  name                     = "sa230728025103955334"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230728025103955334"
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

  start  = "2023-07-27T02:51:03Z"
  expiry = "2023-07-30T02:51:03Z"

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
  name       = "acctest-fc-230728025103955334"
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
