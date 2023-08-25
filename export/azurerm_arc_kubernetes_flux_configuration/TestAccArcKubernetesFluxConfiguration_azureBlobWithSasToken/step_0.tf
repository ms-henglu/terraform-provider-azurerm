
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024049889839"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024049889839"
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
  name                = "acctestpip-230825024049889839"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024049889839"
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
  name                            = "acctestVM-230825024049889839"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7366!"
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
  name                         = "acctest-akcc-230825024049889839"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqyyBszZkhZIQLLhngcd9IY7qhf2neRE2A2M7JWaYxpHhIxzmKFt9qluCfow/PAHnZAqSjlyPf5bOiVT6kCONKYl6XeKjyq5OV8EuVAUEzDQ7Wv0JaTbhGrO9yakOaDkamx+wGaEfKUawc/fXXNLboSlFbhP/PJwEcZ9T8Ek1OLgcwSx93ApEMnlDM+JMCC/ykl8lD9yb3w7kS+iVC1ODGp8BjuuiJ9fj4MAtJd//dzXG4XobVPrbd3s119WPuArsiSvQ3LlaIdrIv6ilcy4qiKcm3oyDkfL8to1kfF2OWZK3E2935oVI3OBkFB2cMWL/61/FRSBUNeGhTEfFZSMZV03mwrg6nsakPvcqOkBe04u9SB5IrsgnzskBk8JCH5ZZncLhxz1eDnjgKLOplHc/vBAkq6egYzJdzACycmr3adfZwpscf4WFsH/TjtEhHf56T/s2rayMffamOCE/FmKwuAwZODIPaS97JsH1vxNt5nBNqV/wCxIHInGrf0lhaoXdvf7T6fsdjiZJsZCeXJVZ9bDWIFQN+TMpsL5crn2jhuwe+ZD3Xi6cig1m4f0jL0114NkCCbq/XFYRn3n462DooIO9lYTuqPiGQ9S9LGjj9DqHZx6Cjueq/NnEviSZK5+GyUtIo3SnE09oMm/+cRCg6CoPeEorEYMobYuZcT2F+D8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7366!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024049889839"
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
  name           = "acctest-kce-230825024049889839"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230825024049889839"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230825024049889839"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-08-24T02:40:49Z"
  expiry = "2023-08-27T02:40:49Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230825024049889839"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
