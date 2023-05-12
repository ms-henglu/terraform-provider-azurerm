
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010215764113"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010215764113"
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
  name                = "acctestpip-230512010215764113"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010215764113"
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
  name                            = "acctestVM-230512010215764113"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2387!"
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
  name                         = "acctest-akcc-230512010215764113"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwkcQwvXlKH4wC1h+DT45Gmrly01JuslDr0/i70z8NqjloD5EmKLKwHORdJCcrXnzy7+vwPiIBK1L1zrjhL7W1SQEhWyzC/SIwCVd/e4dTaI1EhWqEomIwWJEQRhcQ+vzg0mqK51q46mbIC88dua8Dm9KCWmS+BYqgqXrYTAH8eUP606Lw6bIUO53lfw5c03AlC/RRqgPoj+Y7jNuHI8f/Z2wBMxaIlX0ljeyi+E22ll2EuYmelDpx+fIXpCxXkQM2H7xsB9VPFzqJTUi6nwy/5eTm7R7fdJKeZ9nLBX9SmjBec8w2HZTo7n9WuxujRmPdtKCWYP9qa33bX19uDCAxPoi6t8IBE/tIQx7SEiM5mG3PRoDz9+jIY5PDrUAQ7W1wFw6yNC4CC/LfIDgGzVLzdyETJ7de1vx96JmS3BiztyvZHiln6c2ZlFM+lXEmOvO8MZJYJx19CXQBHpUa+PULyPOUrdHKCgO2vv054GLZe6dx826kZka4hz74dHK+CQDzzdUZoKq8B322J8Wt77A2Ivvh/YcBRKPKKpKKWLags/GBEzXc3QtLDqu1tTD7R1sVE/taL/My0w09lKVPhfXgHAV66t93GXZQMvVkLJRKxwQyIYgXPIVyiY6malSVehMVevki/+YU15PWI5qI8T1vkutLfrxHWZd5wgmaXk0hDECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2387!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010215764113"
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
  name              = "acctest-kce-230512010215764113"
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
