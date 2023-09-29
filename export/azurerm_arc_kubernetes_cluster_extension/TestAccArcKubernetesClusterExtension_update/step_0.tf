
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064345633130"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064345633130"
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
  name                = "acctestpip-230929064345633130"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064345633130"
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
  name                            = "acctestVM-230929064345633130"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9890!"
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
  name                         = "acctest-akcc-230929064345633130"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuB2QUcJ6UvQqolio6axNT5hVCacfIdWB9eguwJlVb4RooUul00yZMygyHjFWDZZHpt3+h7wMYeEactAy6LlroCOOGRM+2MJToRWkMJPijTksT/xgEQwG+QxxPTx2LDNITvBHgpnckWHmbXfjJAr0CrwPtbdVMp1JIxQbXPlauojWzOcRzCRYnpmGEfCddsoXL6cxMGycmW/0wD3JfID3pVgyTmpSgUrG396jpGoTgdJGWiwSj49xZKETUGtnZrO6zljGzAmG/RRMNNzag8WgZ0sB9LRH8lSaxLgtzlqHM3tdBGMU4KOPZoucCWa8XBymGlewdFoTYvkuq/fydVpsyEjnPIcEwxLvxO/mA5EKfFSbwhiDx94+jNvqasRUjT9hqfhGI3A7AOKUMZYK7yQMWAw0r3m0eyYSw1mPJErd5ZDxaoMkKH2mSYVOIY20eCyAIbD03O/Iq85lDp+gUXi1HwaxxcPARCfi0laX37eGH/5VzIHiylsJOrvNCpfTawK+dAfo05+Z3T4K6+1cWYycHo4yQwA28x9I/swCokGFJFW2RyMyObAsSm8U/LFrWT5JQjSrPP9kHDt37a+4KYMYTtI1QBWIBFTL0mydLhiu/g2vOOzTPNcZAXr/Vj3hsX0JiFdoM6IYVPoxPswLw1gmpbj23Vwx+O5avXIvRQMMx4sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9890!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064345633130"
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
  name              = "acctest-kce-230929064345633130"
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
