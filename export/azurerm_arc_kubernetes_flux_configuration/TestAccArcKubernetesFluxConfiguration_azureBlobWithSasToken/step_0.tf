
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074312868206"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074312868206"
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
  name                = "acctestpip-230616074312868206"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074312868206"
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
  name                            = "acctestVM-230616074312868206"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2212!"
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
  name                         = "acctest-akcc-230616074312868206"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvc6A7Nn7D6cNnWvrhDmFcFFCpkhxNmaJ38KGSSZW7CY08KbJ+vRazVTB9Ml1gVE1g4q8+azQd7CtbOr2FrSl6gUlb50vhcRDkkNsxotZgGOnfwPMywowdmRtF5akZTP/TnGhScZeUMHv53vet094B9DQXP6Zg8jP4pZaTvBz1PunaLPsWK5Z+My0bDwabWze6UhjqGxDxhwLl0tfROIbjm1SEUv0P5M3DlJP6J6jv29GtFUwt7Z2GDB3UrR5c5eakvjPtxJsPQwIPGNx+HYPQKHu1Hp4NAFE7nwnf/39hHlOWU+VtKEysbwWNKNdssCwVUIAXAB78CuwEd4andiWLjpeWnzO1tvFH4Am5z7RZXOl5ewZdzA/RVeGJZEnr6Jvv3OK2d4NrLnCxVdoMf16e2gQxwCUcuus0+Ua6j+KOZHEWyCc1YSKc/e3hJTP+Yl/oHnCauM51eB5jeQvaAvaBkWe/SMUQwlNwmJ33n2qPw0mWhS7w35jAIoEp/MsKxTrBQ/Fp6kJxwQ7PvFoFIfSLAvAvEeIFcNe/+DUj2CL+cgiWk8ii9EknL1t5X5NsMFwdRimyNUXLqQfkTWosp7x/MY05Y/lvlpraPS12rWVEbnxc6zDpnn/KN0vEsWBVwbI9FR/yssHm3a5VZkd9H+6nB3AGgfASEonFCUoMdScM2ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2212!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074312868206"
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
  name           = "acctest-kce-230616074312868206"
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
  name                     = "sa230616074312868206"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230616074312868206"
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

  start  = "2023-06-15T07:43:12Z"
  expiry = "2023-06-18T07:43:12Z"

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
  name       = "acctest-fc-230616074312868206"
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
