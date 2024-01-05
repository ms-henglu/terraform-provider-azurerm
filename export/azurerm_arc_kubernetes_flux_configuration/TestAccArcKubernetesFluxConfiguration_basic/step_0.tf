
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063258908725"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063258908725"
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
  name                = "acctestpip-240105063258908725"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063258908725"
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
  name                            = "acctestVM-240105063258908725"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7821!"
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
  name                         = "acctest-akcc-240105063258908725"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwwgxe54XaFMX8OWv2PnFY3ljtRwEL4gaEhSWIU6VyvN4z74Gosbn+hZQDNXaRlPckkr9MvHOUI5ICVPN/SuQDT4TGzFZaziA/xrPkIiNG7t/4zX/Bwh3tCXBCKK6PJXC12ak03obUazE5HAJSQJbH0Bg04r4gnYoNZjUGJpG5Er7X+jh2ooKHPMgsdT9AhQmIAGUWXzCGCKQ+/waEmeMd8IG4UulwN+A9PMzQ928limN0IWwgDA+jDWSrIFtdyeUA4+TsHJRQfyI+USMhDTI/u1k1WiFWyPQ2Gx7tVXcs2ZXIRVMOz1nGw78wwIZlLEdiBCSe/MvRIcs1wOCRTqspOSgTQwb+aM9icnwxJtWBtC0hTpPcTJrH3+eC/B200jetMW/6n8J9LjbD9/XNZO1E/261Bd13LjqpKu3xWtjBjk1iTSw/+2PF48HW61ltyg1hgP7FwBdbTGF0Kg09TU0pA8tlGrTVCiiaoB5j+Qp0c8/uAmc2rukWo2VLvEc6U1IDN2Bic0CzXDDS5mXRYisbv2bcMJiZATGi/2DfTcQn3YLmAy8h39u/iRz47/+lFM0ov3yrNZT1Ryi5rFkbT2PlpJejsDZQCzrO2cTnmHV4lMy8o7kVtJKtS1JfVAqBnfwxaH4lJVgKFRiOtRXJCYJd+f9r9GEILHBrekh5G7yHKUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7821!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063258908725"
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
  name           = "acctest-kce-240105063258908725"
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
  name       = "acctest-fc-240105063258908725"
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
