
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025047999663"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025047999663"
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
  name                = "acctestpip-230728025047999663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025047999663"
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
  name                            = "acctestVM-230728025047999663"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6442!"
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
  name                         = "acctest-akcc-230728025047999663"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwXZG6rmS1tTmeCaqt0yMqQW3j+UALPT9u53dmWQsMIfVaJWSue+P5N1ZvA+uCfHCyiOwCUPYb/GrrkyUbBDU3CDHJwYAyaSSk6HQXCjIsX8QNwDw24LvGkeaTWkJ3W7T+P5JP7nAGZhBQTeJTrWQPtp4l/bogPvgVfdJNvyx0bJ7y9Lkih3x9AA5+8f6igWs2SuHOpYuxar96GrW1Eqlf5bY+CDLiNbsgkt6QP77yROkz+XuVQ1UPgpPBpOd+oYhtGL9zReGcMJloyxofbtoa7x7stMMU8uT/BB232GgQCZHszhhJvSJjxuxU/85UO4bQ7AYygqGEkq73P/pa01zVHKp/53hQL4j67exIvdiIsJfLO+leaXL7CG+vfngU+2zs1KlOtj1jxLq5SLEpSCac2GfYfagQe785xTdxdqkfQ7PXaiI/GOCk4xadxFyeMA8Pgftk6NsMGSsM+N94HZrJDcGGQCgwtihcaAgm5FPYeJJn81AJhK/T6KRFpO0o7mrd50lXpGaIJS/may3aTS1fNDhFrTkKhs5ppQBu0jqU9h+A/3RivEG0LppyYobYuh4Ym1KYNRp1m60Fb2sv2xPA6R18eBKxU5kNptXoeBPKSEPXlRyyINdxkjXunDETA/GPFGkyVnwsDggELu0BgTkNmPa/u+ryiFobMlogipNA+MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6442!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025047999663"
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
