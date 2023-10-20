
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040522529417"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040522529417"
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
  name                = "acctestpip-231020040522529417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040522529417"
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
  name                            = "acctestVM-231020040522529417"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8519!"
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
  name                         = "acctest-akcc-231020040522529417"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1DDLacXsD1joFp8HCIgnN5Gi4OSdWdhxFH0IE9mXSguTlHnmza96OHpN9SPolVcdIRh2pZ+SbLv/GGYRYbiB6wZgjmJ9Bf1m9e0Mft6fYImGzjcsVRxTo9RIpEsVzq72DGusAw1RWpm1r/SVsphJUT2v/qLlEzmVhOuEa6l895ZxQuh5NggVkJO4jnR/UB373qFC44BWZUPiA2bk7tYauFMaemLpOMR5sxHwxCKHxP9PhpP0lWYGLP20c3wFfiBLZfoy6tjkN6uVMlY5e/FKydcmzfvb4/NiTlWqzls8pawpJFkyolU4Qd2CNJ38TQWQiBQmgUKopqTGdQFRge4BBVeAQuIiTiF3ZDX2QchvYwfhC/gocAX+kSbKS7tJvCcageUPwRMD9c9EDo3U7rf60eirtmXQZ8IQsitsAuU1nrlC28s5NVin6R1xJD1jp2goyIr1o5ccYpYdatZTruZO3gvQ76TqfwabbBC2txNn2HqKVKHw0hD735Efirqjg1QlCqS8sEef+ZEuZbIHmcpsgWmN7GppXx/ztVDtFQQafK//Wk5t8jWaKGMsup/tLR5NJTW4L1nJ3KijYLQu9MrWYq93OG7jqTeTRL9wXoXOpvgVGDR1F4+0QUfMlkRna/ePgYDBtfSOde6NDEqYNpyfeJNDtiOsgkseWAhqRKRSqP8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8519!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040522529417"
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
  name              = "acctest-kce-231020040522529417"
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
