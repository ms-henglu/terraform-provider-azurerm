
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042924250902"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042924250902"
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
  name                = "acctestpip-231013042924250902"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042924250902"
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
  name                            = "acctestVM-231013042924250902"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1473!"
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
  name                         = "acctest-akcc-231013042924250902"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsD2xYsHXsUR6Kkw7vJSdlx9zjproe0LvvyIVyFcfjszORaLi/+n2I9xQEtVS9YeMR4c4PXqLelGzSquXuwjI/cBDw6vwlcvlzku58tuyVKprZqZBwKntSYrBwqmvOcuGKxLrqceKJyXPEQnVg8prf/l2toWP2J7YPMvo/glsFThQtsWThK9QaPzG+ln2e14P3okpa+ZeW1L0aH01fRvgTtQgIPd74A7pBS5fsNaLmFm2I+9NQsBiBgvAsCPZrVnDW+McBOMepZllWXcOzFIJSf9lyklAWgSy6Q0DpAPCgaUOAubMh58ceVxMuWTrcWDge8ISPwMn8rsCKgUxnNb3GTHqncePmoTrvfJmhFN+OtB8gVbP/OqnwKuQ5iOU9KkTPV/0kqIKInBztCbI1Q+A+PB7Tt6BVwj7naFyXpVuaih9Nq1doS6Z16fdqaMEMVlzp2pKuctW0xmbaYrK4ycn+pgk2pa99zBs9rBHSz4iHchdPcf1KUR0rVljiy3PIKAg5b7dLpY/0fdt67xxEuSKmyREluqEtDb3nOYHGE8AcUFZbEzN/HyM8oq7XEzijHEEBa4srKUS1Qk3OP6Sfvl994sqTBv2bzS1WNYSzTDLxpdgi0a0X7j8JRZau850YQRBTuYxBopY9Vd/+Uz1pIzYNXELLqoE0CFhrHnzi7bTfDECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1473!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042924250902"
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
  name           = "acctest-kce-231013042924250902"
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
  name       = "acctest-fc-231013042924250902"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
