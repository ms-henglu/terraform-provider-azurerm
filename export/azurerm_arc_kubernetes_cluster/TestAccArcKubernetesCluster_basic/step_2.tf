
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003429169791"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512003429169791"
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
  name                = "acctestpip-230512003429169791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512003429169791"
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
  name                            = "acctestVM-230512003429169791"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5082!"
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
  name                         = "acctest-akcc-230512003429169791"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2icnYBQHuqhIXBTTlPec54LSBy78NtIrNa7HAu0MIdBoN4LMaLbK0s715ceGYF3A8rHMYKKqURqodpsUpdOqTa5w+NsS262leZY8LCkygqVUCX5FGXHSIKpoRWLep/5ZsQErnu/mvPn4wD6/s3eBo6xgqsWCL8v623ZRMf72DiiF4CZ6WDBa2w8AzXD508wXilyhmqhuJXb1s1TPeS1NWI7ivZmyX2AH4A8UyF4SFSjnA9sZdfVeG80kdax+xZwmt6JnDhKITi75WuoQIQ3R4liKmZlwivMwnTCpq9fjNnXD6Tw/ynS/3y/s2d7ElPVCJ+v6nSPHPkMNEH8FTUYjeymY3jUh9flyGg/uD41Hh0NIyoZ4AhearR13bmuynt9hcVkLGgzgxU6jL6b81W0ypLG4FvbVkuUh/vyuHGNlVUEnarX/UyatPlE6QTLrk3mhvq2RTNg64Sq1EwvjxpkwX+5G9twsCC+LY9r6iCgWX8rzMI/kGVd0WQJpy2SDi8L5A8j95Eyrm/v0eVWyokYRwYELM1OxdQ1nPeIVtBastVJNsowGNrrkx6AiA1buaRJUifRWH1Fvos9i87cnk21ATFP958V9PAV89VrK61/9c1AWpjbSS5F2oSSNXTdE05hZZqXK17g4HmKDqPM7xf25b/POy7VblMCde4BPZ3cKfIMCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5082!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512003429169791"
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
