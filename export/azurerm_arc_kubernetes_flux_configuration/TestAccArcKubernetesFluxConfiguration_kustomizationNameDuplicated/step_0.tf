
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053640506936"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053640506936"
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
  name                = "acctestpip-230922053640506936"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053640506936"
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
  name                            = "acctestVM-230922053640506936"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd52!"
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
  name                         = "acctest-akcc-230922053640506936"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2bua7e9mrTXNV73IHuDLByTz2oGecLGVmmqDW6jg/eHZYio+i4gvsQrGInJybdiz3WNUj5+z86/MpnjFD5WCVcG2E4gn0yNAzPNKBpnn+GJ/kGyytzUB7QhcRCMl761POzPcJpiaRkOooOi1pgQwb0w2L7p4r/Z59d+SzCWJi7zobHI91zUacTADiVQh2MNH3Kq11fyouVH6H98Exzsid2+j7LzBzTEnW986EhB5ZD05tgTvu9YafVdP68nUAtuHJ5zTAMYo+3vLORY/S4pBULeMK4Za7MzdA38neKUlPsHyCBX1qMzQvAoka/CuCk9Vlc8+NI2x1ZI2NPiHX45vILYt/OWHB9XqC+lhc1OcQX2enQoCUtr3su6dQkyh8o+GwAK6o26iS2aqP1oISOKOql0xbgawuzvcCLCh65zNEA2rTcopEtsL8sl1PfUviWgOXCg4Ir3vvYSeN5kasXuBzmgssmL7mKsvvHG5EEF6TRuZ48lXdcDN2qb4jQKZ+NFxOV5mgOt1dx0VGOZOF627oZxSlXcyp245UKU9T/DGWBaZleWd61yZSka6mPzdroRJDzrE8Shikz4taa3WtTUDjpusOS1nhdyUU747TlDAxWer+4YOHMdutBP2FmkGIKsR3uvEW/nLGTjRm01Dn8woLxFINzfTSkPv2tuQr6fUEJ0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd52!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053640506936"
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
  name           = "acctest-kce-230922053640506936"
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
  name       = "acctest-fc-230922053640506936"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
