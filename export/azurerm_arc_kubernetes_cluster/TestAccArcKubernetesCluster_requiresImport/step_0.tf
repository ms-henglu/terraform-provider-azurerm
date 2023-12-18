
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071229681290"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071229681290"
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
  name                = "acctestpip-231218071229681290"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071229681290"
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
  name                            = "acctestVM-231218071229681290"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4373!"
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
  name                         = "acctest-akcc-231218071229681290"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAp7eN1sC5N4SxUTQpSrGcLWszboGsB4QatLnJSlL5XhVTocpbtlyfD0gf5QQRRqkNrhEo4F45fL6IgyXUM7o9kTPA1RM+UyL5sGOO6/xetg+UdSIKEElAdqZIUnn3ruWueaReMFZHArbOPk9+JSrA3Wt9pYJI9+DBYmFIirH2iSG7xEFtb/bm+ynniz1xQffdaOy7R6QMYuM3tPwXH1E5cHUpRPgG7pUJCTGqNJfiAZDRFYqPNSVIM1ykC4FcdupnmZ6ZhbJdy30AO/MxMEwR5Vs+hZ9HzJK6uzasSLwQNvLwLr6jzTmsfF9UctLJSmk/koEh6I2DQtKzmQV1TGystmY0H5lNTYUUcLtsqjeicEpZP2NgN6Btot7bMDOBaaSGV9/UepgID1CwDMTkd2rLn3CnvtblvCr8Eok2BJRmZGO7wzl5SsiDMPtJIJWn19vb/jGWsL0zlDhmOjYKdB51r/r8BRJyR1o3PdzYQTQpi1QbM7Pv1iyf+ZSZHnWeyByW2vjYtmUZKoAmtkuTgyjwBuR2Yq1AyjAVJf5MoKVJ8jnBi+aY9eaagfKGWDcIsCHe9hZi6sQX8HCzukrik5GGj7Qoq2lwPlH3XgpD+Tu0BAbZUstGKEpQTWzey+9VZ918gGTfJh+MDaa1o8gLzQQ3MuxEqsWokaCZK4XyN6Eqx0sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4373!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071229681290"
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
