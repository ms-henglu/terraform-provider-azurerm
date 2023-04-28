
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045210863125"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045210863125"
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
  name                = "acctestpip-230428045210863125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045210863125"
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
  name                            = "acctestVM-230428045210863125"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd157!"
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
  name                         = "acctest-akcc-230428045210863125"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0KrXgpSWkPoPOI3600cKYPekdai3O6nN3Q6xU2P0pny3a48kZ3nVLzhZ9Eay7sQw6Q7MqiilX4H+af+KdvbK08TGmpzJlUkyHCVBY8kN7Z1c/sc9k/XAjCvFni9cUipU7iuceiUAzJIrALJViA/0uUxMiN+XWZwW0sHXuangkmXPwvJs2IDYOjYNv24CXyhSB+v1k+Bf7ncgakLImtOZgPx9kek+8nUITrg21IL0Cj6/zJqETzhl3NFHut0vP0gmfho3U/rnvNO44FHAtepT/LXKSV/41EH+a5m+BTmIIYgT1FmOZPlqoJD1LlZOhZcB3n/qByiTT50fznNCQLRLfqyYeHXrTAJStv2upIaMU8x9OP2s73DAI5URFdtVEeIcr3d4Inj8EQEn2eYVYFpqVTgqzsrrE2UtjM14TIs0NZ3VKLKQqa6cTr0bAFfxt7SoAbqyrbswTcIgDfmgwbE++A5YiycNqXznJZczHW1EkVqvhHaLn+4DyY+mHmfBHKM8eXkwgJTOz56a1Z+4R5c01wcW9i/o4pVE1ElofjIPRn0NVBUZPBU1mm7ABunOvOzwU4UUXTLE3f/e/KdRSOTJjKzXirj9XGnSfpAf4LtwiGocrUW0w8A6JGf0l4D6HtL+2+DV7Z1Y9M37UVa4LyrFp+9B12ayEvuimcgt1QXLddkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd157!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045210863125"
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
  name              = "acctest-kce-230428045210863125"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
