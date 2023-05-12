

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010213304656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010213304656"
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
  name                = "acctestpip-230512010213304656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010213304656"
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
  name                            = "acctestVM-230512010213304656"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9742!"
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
  name                         = "acctest-akcc-230512010213304656"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvYE2vEPL+PVojUQHj2hCkwygeHr/ftgj0+TVt2j7PaITyEMeZd+S42Bhodc7EMjuSb0Sfq6H2ODjMyidM+Vp54gJqtMLUFMC/vJ/R4f0G2Fpeno17kSLcSv2AMuSt2uWvYOTuAF1ghTnoWplS6PxgUnl8JxJF//lM+VYf12Sv0Nt04q0A0HfdCYGS6Yw5uegPg72/MWq7W8uGPFS0C9xbflbNd5IX8XRSSVz+5s1F0FBxN8SP6QEDKfcWL+tyO9xkyJ9xKrmql6F7vGPcjoAp1qO/hckkI7QSGEVifA4sa5XXFGq7t6pMb6c612AR8Y5rKDWDnCa5GLwLmBva4195WfuikDHMoE/SbCZqMC/Tw25+SUkZfp2m9c+YAgPUk5fa4D6xewtYF3PYXLhhxTEg1Nrw5Uzysx9Pi0E1IdNcARDvGweaQk6aNF4GwF4ICaxeHCs++0wJa0HdLt0PQWW76fWRYxyr0fn3eHcDtgFm/BZgut/7ZA7giJxQHwTl7JzUK4ciTfGeURvvJJOTrBSYNWChDGBKnAYh0/b2nm/ctG+t6a11MBs/g8jtsEMGz1B//XMqTxcm/KLM5HP5uHZWYJ13MDC2q18tEac6MFmbcOIZ/KAoW2zt6agtNQmsOHltXtPecZazKlYGzHISVyL/kLVkpFQAp6Hiet65x3H2Z8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9742!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010213304656"
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
  name           = "acctest-kce-230512010213304656"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
