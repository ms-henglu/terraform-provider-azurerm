
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021510569843"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021510569843"
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
  name                = "acctestpip-240119021510569843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021510569843"
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
  name                            = "acctestVM-240119021510569843"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6115!"
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
  name                         = "acctest-akcc-240119021510569843"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAw+QgPSxd/JSivLKpo0/OKFC679Peaw2RbVjzpzZ3dmkKE5j4nN80q6QGlhpuuopf+K2NHysnNPz1WJQRXUHxLammYHBxMp6/n5b1FDPDzQXmRFaN9nc6l1utiO7dvmUSadO3jS43zxW0B0IVYgXEVTqy7gH40h1/hZdLUY0SZDZ4WsvrupoM91PFOqsiMjrMmrMvpQPQTexNqlSbhy693b2FhvpP+oWmkVsRlq+vl3IQr5iABcCTfcDUGBxzBoDwwQURVF7Qp2GWebiSHu2ckZcE5ArSEaKraDZBxGJ0wTJLEnh1fdPEqeZVQUhmYErDoHK84r8DwH7Nc8HUO7aGm89PI99lcTNi17o9mU0eelFLbqOkS/+8EgCukUyfKWqG02o9xUC1aierACoCuyJeO1jV2951jvAuIKsy8xQn0OrjWyoU9IZnCUvDDgs7r369lYV4PbodhDoIL2ghjUSZpwq5RoSn34K+MN229galbrB5vritP+oGpNnYCWym/6n2dn/RugPuIV69hhbNa7fFgGr15s5rlA6fp+2IsjZGMHffFfo5rq8OBWkvHHSWZRkl4dBahdQtZmkZCVu27K0ysaCq86YJW3UUCecsh1q6sKAYA28Ukjzvv5edWbmdDrCUhXqfQGrGw6+5Lrq7cHFectzV6Ciq4YXdAfQVmcs1fe0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6115!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021510569843"
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
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
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
  name           = "acctest-kce-240119021510569843"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
