
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024034930303"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024034930303"
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
  name                = "acctestpip-230825024034930303"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024034930303"
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
  name                            = "acctestVM-230825024034930303"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4602!"
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
  name                         = "acctest-akcc-230825024034930303"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsV9iDXi/vdidu3a6qkSG+CKmGauXQcUiRQY6u5868UJDFStY1+XhvSa9mZNt75pv6+9CQLnG1NG9cfsC/ITo1R+4VZoSqjGOO2ZXTsKLhG0C9seSX2Mi4Lspg9HgEOU3cRqS5p5jHsQm4nq6dpN3IvGcIeke4AbF6GcfCSUBr61zu8L0fR8Udwq/i3K7gZByoki6jsGnkGWrUj7FKt0EJhw0+4sUx+aip2QjUJtLQIL+u5ZimraTRDpkqivYhkPWmEpF+2cZP+doXz4bpu8UnLzmj1yuEpcoOb/7tPuhq/DpyXO0mVhDFO4U+slVjumLO4eRxzec9hOebGMdTt0Qv8t/sc/ip4M9NPzdCaZPEtX9u70ArUvfxQh2qXnM0JgN3Cxutc6OOhjTQmtv5DN775cIHp8Mh8FyDQwW9TOmYiTI1ViNmln9nES64wdCOaZ66xWnsaYzBwIYSOJQ9YYSxxJW+mE+nJYSBMaOumoNOSWSIig0GCFbYP9O59FrrBHze4aeUm+Xa4m6jVuP1MGul+uKOCjv3I87zob391ob1NXtq5f4Zs5Gs+twphnCPXpo8YJKU/GFryWdenPJzfpMnPKV6780LiZ4jXuOAIyDXpOy30opu7hj8uhYZUDuMLj6GtxJRf6PbKrNP1YGecw9xKIqBW10jU3DyWrS8xXsWNMCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4602!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024034930303"
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
MIIJKwIBAAKCAgEAsV9iDXi/vdidu3a6qkSG+CKmGauXQcUiRQY6u5868UJDFStY
1+XhvSa9mZNt75pv6+9CQLnG1NG9cfsC/ITo1R+4VZoSqjGOO2ZXTsKLhG0C9seS
X2Mi4Lspg9HgEOU3cRqS5p5jHsQm4nq6dpN3IvGcIeke4AbF6GcfCSUBr61zu8L0
fR8Udwq/i3K7gZByoki6jsGnkGWrUj7FKt0EJhw0+4sUx+aip2QjUJtLQIL+u5Zi
mraTRDpkqivYhkPWmEpF+2cZP+doXz4bpu8UnLzmj1yuEpcoOb/7tPuhq/DpyXO0
mVhDFO4U+slVjumLO4eRxzec9hOebGMdTt0Qv8t/sc/ip4M9NPzdCaZPEtX9u70A
rUvfxQh2qXnM0JgN3Cxutc6OOhjTQmtv5DN775cIHp8Mh8FyDQwW9TOmYiTI1ViN
mln9nES64wdCOaZ66xWnsaYzBwIYSOJQ9YYSxxJW+mE+nJYSBMaOumoNOSWSIig0
GCFbYP9O59FrrBHze4aeUm+Xa4m6jVuP1MGul+uKOCjv3I87zob391ob1NXtq5f4
Zs5Gs+twphnCPXpo8YJKU/GFryWdenPJzfpMnPKV6780LiZ4jXuOAIyDXpOy30op
u7hj8uhYZUDuMLj6GtxJRf6PbKrNP1YGecw9xKIqBW10jU3DyWrS8xXsWNMCAwEA
AQKCAgEAiGOJ6EYDWp4om6/uVWMgTcmG45JYWtCVS3JA02jbUAzdvHd6d3ljHame
fWsqS+X7TfbKgS7ZP2iQPgcAAuDIkKk1e01gMNKuReqqE/vwgEG617waR5LZjOke
QSivHQ7ElQoUD5WXLl8yb1Bj9S3rnEkg/8pcXXOX1t8EtGlqZIYByk1c5qFxgSAY
rcfpevVx0GwQWBl9GcGz/SgbQJx2xj9GVm5Z6mTkicasiR0Avnh8HA7Ff6YIk5w7
L8dLVeLwLmZebbSXa9YrIaGGbdTFisiOmYpwqAbnfZCsojwj0y0K+EcqhgeifYOd
SkJqsdvPnlTeuct/vJDVbw6/yJagezHl3IR2gnx0zCjAWoL9JC16w3qFij95nxOY
A4IIBn7KPJ217dyozNqi8wFfD1sH1Qz8Do17wMOHyN12KljtSqcW4dL8DMQl3z6l
s1v2dBOFxawp8St+Ml3WoArizk4eowG9AL6wKLfpb4siQZMs25AFK6WbQA58IbvV
miKs1znQmb8oTj8KFYsLRPr9JK2ProvIV7OOOLiMcUHu0l56XZmN8BDgvN8+SUh+
6or1sPaT0ydZ8HsOEYaeYGojeVvM1RWuxFfwTF0x1zyQj039HiWFsbRqbUsy8++b
WoA4L3SWxou4GDkdpk4LgLQ0opkl7eZV3978HRHkuaSpkogjNAECggEBAOa9eHKP
Owa8CKq5HY/niGQb0Uo2vuQAnF07gLqKTDsCBHwHOK/yuddEyWujrP4pOFqaEPsx
60Ne7NRtJfkHOl2J2FAsLW5RHT7Fce0wKC94kketGVs7d+GXWsbAvwHIKqvu8JlC
AFQKXjFvPXySREcbhuXuWu0cjnrRUsAQZu+c7jAx3ZtrQr/gRgIkZ8aOuPqTvTmG
SyxZss+wbHOuGWBRorNOVsMKhFgJqEiS5/8U+Ce5ecoUNVBSUHVXGepJAhIocjuc
6xYyick9bRSi8kurDDOdm0Up0YYHMdzPZ7PmnK//BPpWeimjjwdxbI3QKkPkxKND
jSB5GuYtZmoIndMCggEBAMTKR1+bTO9Qxzi6SwZ8T9wHXEizfoTzO2r+keHGiFoo
OOZPZDwg/BkzxtU3knGv+80kd5mz3sT3zcNgqK03rbRm11mmi3h09HMAJn0r7NFu
81kHn5H6Yl9MFCYisWLpSHy3syi8OtgUzOm/BAmUm0tk+w2ReRVBskzwezBj4t0m
WG0E45NR5oo6G20zTcvo0Eh/EBqc4mXQRLWaSJmTO3HP4gHJ7O5lMud+wBNn/HLm
xCZ9lvtOQjQ6hE2TAR6FgWcwmJ7D9DmaY/rwZH7/IsLDcSKyr2matxaB4GBbixdP
41AMvvkoryVMMr3jQkUKIcIdB2G8tbHCEDggQVOpeQECggEBAMnPXdGUxKOXQl1P
mzOJ5hjo25x1VXBFuH0y1dxRqWrS0OlJx6LcQP6vAxxKA7wogUl9Bu0tM/+wvqLs
9BFi6QF21uMIQJQEDfgg6Qvy2rLqWcam9058LNX6c0Lywhzk3a2TRoxE1dSrXMcP
7E9P/rfSs6HXX1+TYmq5Og8SSXW5Y/pzIsgUgEUh+xlUjg90NQW0wgPWGVmo+mP8
gl6LH1bHD+6Tzf647Be0GqOfGZpY1NKpvoOoORkPZZ+7lsb7I/yNs5vAGz1G5oxE
VWt/OTxFVl6usmdDtCXtlQbzwFfwk4q7Gbd6e05/51EzOyatssm/BN1m78A/K++2
NaT39FECggEBAImbNKt7CiIyJwzY38uKM8GU+AfyU58eAkd/+XyZ+hCpHZiWnW2a
Vw48cWX49RNATuAVBvjYmQa8jQp41ZpCW9nRK/cJiW9SwPiFe2R9yZxtbAauWPuX
zR/8L/62tbmHjOOBBOuQK8mbSeqNYoJcgvcGhrLnLXcauFYqtsmQnzurK5wYFhaW
55Fyrmj+vgC/LJ31E8q4N2ugZdtjJi8VkDS2e8BqdZ4B78WGkUNArHugODr+CQxz
ncGtxYQFLnwsON9yUNZ8CZQaDJ2VaYCQYbs1NTBhKF29DRfU+5QFj05e04HPV98c
ftSi4rx7ZISoYBC/gcDrV1YUcIj+rQ+WawECggEBAKLrv90lSAupr7tTwLfcODvE
k+9+tWRyLjQQLWvfJ/Pdv9joURNYmgYBhL9M1JhHayzWZkwZd8wz5Qj5U2oroOoN
E5An38r5/1lSxc1No0QPI2l+rfMoMlyJkytq6qdxbsBN8lWgqBXzeo8MR83d6RO7
8wBr/K0T+m6Np+LXnNHh09VToiCXJFPV+08NIxRYAat/fQ2IXalFFdkEVTwSTZgL
/6mk+TTinbVbsrKYfzCujx4fpaKbHriMFNCDWQWv0XgYHbakCdmFJSF+7ER2jJzT
STDuKbo7FbSQJ8McB4r6j6CVtKnG6cAk9CjTD9gZEJEg5XRbbKNGSe23KUnjVY8=
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
