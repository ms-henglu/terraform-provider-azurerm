
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024044063401"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024044063401"
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
  name                = "acctestpip-230825024044063401"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024044063401"
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
  name                            = "acctestVM-230825024044063401"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4859!"
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
  name                         = "acctest-akcc-230825024044063401"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxbEmgMVJIOIFiIne5BcNUriOCRTrW++3PoxUeATQ4sMgpsDMSr2dTPjoIBlrvyEFL9Ev8cKHQDcAiOug6G9qs1m3DN/AkMORdk3D9qnRYQ4gGPKvPCaMPtve2H74pjKV/hu8rHr7auarTpi9m7wsxokJ7kCZ7funC6RUpPU2gvC/83SgE/8v6RemMCo05ODOl5y+8A+HlFR2BTP199l6hxINlavBQ6gs2fF86wK3VGuNlHqqIXD/tcuM2ac6vnnGxKVP4Pk8Fn91TDcOZMxkFgjqYjj1bVJKTMDAuIQJPmDMWkdyE5BEC1j5tkZZi/sQ5tyruhvUOGL1zPctPRPnNIwGNuUGectE8t++lLfEd688raxPEY4GpimWlniKEIJfDg9xcrrpw7rm1RIahL3to1s/myYONNiqDy905Huiyf+kSLJ/huBEQhIUp33rKDJQBssV5zM1TqhdfMEXx3gdH1s2QeF0q0y2v4AbyZJHVQGcsXdjUBm/SzazGEUlu5Cr66cowK63RP/fVd0Efayglzz0T5JKZKP95L4vAwAxgDqQGrUU4PGWbbvXjJawpJrDOK7ZD6HX9mtyIGIb+muYQpVAgvrAUG2lN+yRhhrWWaKDDB8ncZ3JsM8Be5Bn3Hv3//yjvWkhjKv7raiM3ixyfDG7yrevthafMhUUebEBCqUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4859!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024044063401"
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
  name           = "acctest-kce-230825024044063401"
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
  name       = "acctest-fc-230825024044063401"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
