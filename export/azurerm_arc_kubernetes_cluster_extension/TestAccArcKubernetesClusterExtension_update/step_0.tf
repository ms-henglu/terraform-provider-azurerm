
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031324573076"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031324573076"
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
  name                = "acctestpip-240311031324573076"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031324573076"
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
  name                            = "acctestVM-240311031324573076"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2397!"
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
  name                         = "acctest-akcc-240311031324573076"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv++IILc0Dvj4QMUKVbKBzrM+/ZMH80RbpzMNwSzX+QJX8nGptJ4P0temeHPRwulpbiT2x8X/ZhQ7DLGn3IYh+CKenWFYvTb7Yzy2xqko5L5pKC8GRirW5psHRYXTQA8rNC64z/tchZEwXe3fWqchj81LS1Rl/f/ETMBPTwhlx3FuvJAgAY9F9R4XAna+mS/sZPrgqsgIyffufgubX7Aj+ZCT+fgj4F/SD6iW7Om8Yz6i7dPckH+m5aJ4zoYAIjkU9eWwvGsHlGF2rSsSZhTDhzjSvE7uPQSbo1YdBo0onpYp7ZAHFivOKrgLzQp3FE8ZvMqcQxHi9leRTEz4ygppuDqh8KVX1qSmGHD4Tvk5TSBDw2srz6xRaxJ+NpZ8N6PlxuFVy1wgjz7CR2YF8DLvxVSNtsk2/++YDUbk2ScCChChdfLxZv/2qJ/fAvy3vHEKypiGqY/EAK90Zh/zcsGLFiezp/7jdzhDp+eKlhhhELMVVvppkQ7cMJh766oXVT2g0ycnsTrc8D1/GS9AaUk2fxtrgM8S3sQMVKeuihrgxnZC6k+Do0g00tQmCJCZp4LNpOX+3SIiSMNmUimkcaw8o/6K+RIALc374oSqS+3SNPTWImAnv87kgnoaBwvNNJIEvVJIPU/3cLjq5JwzBudQDnhi3cNo68CzrTVyRQoby5UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2397!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031324573076"
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
  name              = "acctest-kce-240311031324573076"
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
