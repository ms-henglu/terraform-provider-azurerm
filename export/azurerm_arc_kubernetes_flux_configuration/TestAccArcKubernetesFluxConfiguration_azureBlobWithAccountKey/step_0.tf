
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042924760139"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042924760139"
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
  name                = "acctestpip-231013042924760139"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042924760139"
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
  name                            = "acctestVM-231013042924760139"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5603!"
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
  name                         = "acctest-akcc-231013042924760139"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA03OlZdz1Ta04DJ1LjyQfx/NV/oEN+e5g/RCptYAUFNCbVYLTzhKkfH19y4dbYtFdLAPvL3VswdqMk2DyFMlBRcWKnrgCTRUR2w2tvVOYGyCABbsHuVht/psY/lXcv8UgUIpZDZqzyxhUMKi4X4GJMyp395UZjkmlLmC/W2G11hiukPfDRT/KohkQnHiTyvjPcyrhV9EBv4hrQUMfQbolxq+RiOnFTdde4w3/r8shGqUtaSbRolYhVG85O5MKZcit1aBJczu28ERQ/PuwfDIFQ2yfI504oYdXT8CuSQR+MJrdpdvCaEiDO+uVOzpQG5MpMm6P7v9DkQScdJAUcFFRwSimmAEhtUJmMZci7gbCHqglRvCBsETxJEcshP4RpaxM0GCMmMplLAzR/HMD2JyhGQ21fgv7mf11EgrbnYZWy1zhWsTjWd8SM7Ncgs7WZfnzyW3smiZHLQk/DN/Vv4vm5CioXr0RRbQoFqedHsbDhzmJLGO9m9T9NPmHqxH4GaqvExYQfE5UPM+6ZhdKpzFygIRN8Bz0vvAh9mPg8sZVYuPSF33BxOhh1NvSwWln8Bh65vSLuloj1yd49hdtuiGZ3QF8tz1+Hvh2k0qom7aL5/+6Buo95KwTO2FYNSlBqc4t3vXaFg6zMyPU7ut4pe3S6TCh7hwkSETFhnCTm7dxoQECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5603!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042924760139"
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
  name           = "acctest-kce-231013042924760139"
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
  name                     = "sa231013042924760139"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231013042924760139"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231013042924760139"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
