

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022851867502"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022851867502"
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
  name                = "acctestpip-230915022851867502"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022851867502"
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
  name                            = "acctestVM-230915022851867502"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2227!"
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
  name                         = "acctest-akcc-230915022851867502"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApRqmZbNwXydzkrd6udGFpMRKlwAqba2Y9LWKm18lYx/N7YRAIPAI6/w+Gfh0fsmy7XuSlK3nGbro2AnVifQaPjpcmuSa297izDvXAme/EVcQ/pxc3ustEx4u11LLksbMKE32MPpxPfHTGsk+l3Vwfe8aAbfHNjSm98wjLAIa6MR3trUitdfn7zyV5BrvdNiGt8guQgF6ZA6yz07muEoY/HdhL3bDkIMZhAz0V6pwj8sMTmitrtC8ztA2wVFo+orKbO1VK8qpxj3Cg2vVXPfLUjqtO6m6nkjyHg5Bh+BIKPc19oVxma89z2K3EfL9sNjpagjBnmHBvP2XhAprAGHm3GM+dXPDBBNvb82kfrLmGsEOVfDbOAn2dMuy/ovqoagx9ydTHbCwnnfoyjQBBnduLrU5rdT8VFdbh8j+izVcjyFHGDXRzpETYp7Jbc6FAeLjuJDLJSxkcYXV2VWMdpoUlxsP4K9PR4ePNd27NGXp6dcgMSuTwqCsFNQ95q00joCCvBs8pvMlx9z4W9Gp/yM4mj3FMPsUObrudS9WwnyecA48qtWA1BcQq/gH7B+rVM7gMZRaFfHMroKY8V+mjATn/GVkB3phy/T0zB5HKRQDsZMYTWAlsqp55AYED7MtrMHWG0OgOW2N0EXEPiHg3RDa04gMRdYS++mUoKK/OLH5lscCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2227!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022851867502"
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
xOkoKQKCAQEAiYjv7LdOr2HQ0yXNlmMRC3yftOt+1uLyixCSDgK+mis5z3nDRKuv
Q9d0SMiRRkpv1fUJMSCpRr+OaKKtgjABpL7yjKiRF2T2hqJTSUZgMUfUQKuGLxyo
M9Vp64Al6P3iJoyyoQzBesMDfPlx6VVa6sRRmeC6MSsYSOPbDyz26KHgM8xH/qwI
jZFfi3tywcLcqijngz0CcH7HJxh50u2xJPov0uFNd0WG+e7ak07o4W7rzGmvdj0X
Q/MzToME6W7YqqrTiVpsEFth5AvATiuYg086joN1MfiiQ8OPgQJfJp1tOAXI54MR
Wb9csM7xWLH/GizrYAs/X43cptK0FMCinQKCAQEAwc9xlZsE5/3or8KDQfkyWO9z
U7moRIHrxZC8BkfNKIAL14IW2J3GBT/t8SoUFe80oFo/sCEqHdJNHf+H/ZBkXRBE
BPp4wJI82CxY3E9myJmH41XuQXXCy6aanLC7tXJBjwSueY/l0k2AsSSuPFDHC1Le
rtdm8Cgj1PKBuxyKoV7/Qc2Gh2jffY6TxIrUyQao3y1/avwQ1sS9oB49T6jRlknK
UuXdYhdXHuc8fDRQpzdzarzsfx4CAg27anZRmWxyfj2beZadTnou9ylcLqH5F9CE
1v8MytLvXInubfjMixT2tqKCkl6M0LFd5U+1oyHl0je/vKLzk0J1jKnnAqzicw==
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
  name           = "acctest-kce-230915022851867502"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
