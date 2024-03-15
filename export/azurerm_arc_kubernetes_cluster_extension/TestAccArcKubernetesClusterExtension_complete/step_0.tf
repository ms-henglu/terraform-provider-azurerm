
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122302968006"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122302968006"
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
  name                = "acctestpip-240315122302968006"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122302968006"
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
  name                            = "acctestVM-240315122302968006"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2771!"
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
  name                         = "acctest-akcc-240315122302968006"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAq0ZjsMEOWVkCiGGSg/q/CaPZXVE174KncWMLlh3Er1fNo5ZlBywiRfmQ4JPZ9Z9b7qoecDmSdd4HBOP1A/SLQMO0YqVlAzeeD4oSzitGvnjxh+/5IaQfNZRdo2ycoMRUY+ExJNG1ugIliFj926ul2PLyXqFzg8VTX5BYZWwDFpZ41Xc0ue9D0hbhSKlOqY5NAloQPcIRUqmoLrMCgSHJOWB8NkmvwUbrim47sqo8SeSHZE/UvWGzXGM6UaYQOvq+Y5aScBQdXR+nHs8q6avIf1FvPWUw2ZqHROu7qhVm9wW/ygPkJDZ0tNqH+D2dSMiTPU92LwT76T1K2iJdIHJ04Jhs8GzuPRuOOVEc7QhlBDLD5ll4/cVub9nM1yV6WvU2XbSDd7GcKYYCqBFP+Q//u+3qFS1VgoYduicBiGlFAk3GICodA13NSzW6s7lDLgozCZ4LX+vtbhh2f6xMakfyDX6B9HOp3iLPSyV0gdEDz2aoivR70S/GcAph1rRC37QTV0QHhRYH46+n5fQlr026Z6e4kbVzQ76+7mjl0MddzT78+DO9mW70b78IFkQ6WHXhQM/8gv9cD4hg5Q5mqIRjjP24f48bcF13NewRNuD8BdKli5A1+qoFR2Q7MZNaNZ1U1OC36jMjnvrnWgczcF5tksLzKQXPTBfuT/Pks+oAIjsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2771!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122302968006"
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
  name              = "acctest-kce-240315122302968006"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
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
