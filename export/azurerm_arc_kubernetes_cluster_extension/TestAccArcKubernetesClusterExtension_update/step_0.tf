
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060551837818"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060551837818"
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
  name                = "acctestpip-230922060551837818"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060551837818"
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
  name                            = "acctestVM-230922060551837818"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2604!"
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
  name                         = "acctest-akcc-230922060551837818"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAupGqa/ISrWrpQAKdvHY5HtSUssoT6FfscILRGqFXmvazjXRCpC81bQDJTDpNSfcqjFZRKh3L9MV1ywjmCLaRcT3iicJ1qwx8aBe6ptkfw56QfKvDF2NUqmwLp2uDFybY52M0y16K4EXe2p0gZGZpoTmU+mUTVgbeWJBqOBTnAa8SEFf38Nw8iHOeSlkX1+15s+Z7TAP54+D9UHOg71Br5sWNM0RxK/2A99NBeIdH9c/amf4XpAg+QvvGW/jmUUzb9t1gq79KHUWZeYk7rP1FTUAVGRQae0OtKJvLjkwb45qHA7kTflK0m3+GgcSxz6ICQIpFh5WHs7C6gcgvKLSIIBbXzorBJqECdUQxgwORh3vtNDGfd/g9BGRKJcMj+Oe4eMCjsudeM2MjiPZo514q8IOgi67pSNm75l01A72lVsfy9Jh+N5ph0pqOibDrMIh4EWnewoTJ1yTwMoUxhRzknB6Uv+E+GZ5KpbMINoeEUtg5+qQ1e+Wf4i3i73ykiSCzDEtW6H2Z7Onu8b4tW343w7sPwUBvgVdR4gDH7gMRT2inCQcJgD2xvyuZonLTveLOv489dtOAuuVlLb2BufCjDX6UZhb4VZdCJCPRKP0KGO0+Fn+914W/BebRQqopz9GHCjTAqoLMkMuo12IpdsWvGLXdQVwoLAJTPj70mFB6AuECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2604!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060551837818"
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
  name              = "acctest-kce-230922060551837818"
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
