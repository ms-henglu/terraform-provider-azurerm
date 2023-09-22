
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053607736379"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053607736379"
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
  name                = "acctestpip-230922053607736379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053607736379"
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
  name                            = "acctestVM-230922053607736379"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5772!"
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
  name                         = "acctest-akcc-230922053607736379"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqKm0Q5JC7/wju+m+ECt9pcMSRFWhrVnn5QiLsv1A+OyGHBwDq2DF0Ql372SJNUgnPVguENC+Y+tGGQ34DxQEAq3MxiAhNQTF+hLYMHE2Vko/6EDrK0fMKJ5M74FnUzHJoQFQsi6DuRK4qOVeNuWSWx0mzpns9uRIwrX6I8AM1mC9SNj/kpaweyeaNZcRmDzK8E1SDW55HTDg5RVb1IwJRJDJnldUu4HPTCRAuG4wMJv7R4Z8tXmOYM7kCHQfglItpX/G+F/WwVuwhrx+r0oibuzAR3ZVAz3lOqILI5Xf0efp8N/y6Hx8dG9AGTJKUbMo+KfvKwC1z3s9w6LfH+PPC2zzMgAaaGOD5Eqlkrs9RrTg/CTnRB5BXnwhN4WCU0v2m017AqMHFI6MTnc7qjC5rLRY73TNX4uRDoMNHmC6cwOsc0/MHSwmHy9JKdjkGrAoJaphcWgRrZJh3ZjGHMeB+2L5QEX+iuQpuSu0kVN0CuE5rrVkX//T6DJh4YK4jsYP1SmR8wnMvvxp/yqU41TEp2nsof13SlmpJX8y10bNceQCWQpqYKVP+qt/oNCZ8bVL4SX/EHj8ABFURnUBpO727rZs1rSQ50Lsf+zBGjRLqaAYk7Re3aNZpeSz8E5diBkJ5E5DAEuoDQhx/fz+30wxlI1yRDJ7JHazpBDJXsusE8sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5772!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053607736379"
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
