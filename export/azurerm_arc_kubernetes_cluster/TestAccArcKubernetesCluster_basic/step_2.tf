
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074251636022"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074251636022"
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
  name                = "acctestpip-230616074251636022"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074251636022"
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
  name                            = "acctestVM-230616074251636022"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2817!"
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
  name                         = "acctest-akcc-230616074251636022"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA44yOd/0Wr0l+93rlIFcd2TtiHBxDoRcrsrv4U2HVmvlSDvXhsoLSiVIobkCRMMDWOmi3DVErxbXEu2SONup2AD1HWXw/KTfYMn53V7sYLCSaySVXwfwia53aBR1HtcnilrwKfvZeUZxsGYpiVJ31/NDMLLm3OvUFuxCG+kgfR4cfVPlUX3eXXNQ11U4x+gNUu6VmEwCj5/6gE3ZVk45EGrMBFElyFb4D5nSwA+2XgxfNEkE2GZ3gPkWItGV23OpKOdLRh9OjRyiyoddH/Fpr7Kn2Xkff9rDtp4UUSa33Bl+Sroy93bCtlaRQt/ZvuOjmplFqjOItyFwQEWkW1pKBlmMchrtw2F/DJ7QE8DjTdxyBTukCIz0XIAnYT/+pSahZY48MwqnVFVRkf+36ZdBNMQXiAPBy39rpw0qbE4DDmwk5ti9Oy3VgiJsFsg4sGGyGnLD/aoYXCrCPpn8OV4GZbDUaBv343wjf8NdbVMNDpwPUeGGfy1k79szCy82G2KjS7Cg3oxM1mdlRX9wtn2/RGK4+19rquB9wmE1PynwY69PCfzf39aIhGkpO2nrgLSBvDTxL/fxHqSEendjT6/s3xlMmwOuUPODF2atmQlvhH1CFITlqPvvvgVPkVtLhWBFbJs5k25Dq6iaXkYZegdhsT18mfKA9UpfNr96bdsrHm20CAwEAAQ=="

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
  password = "P@$$w0rd2817!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074251636022"
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
