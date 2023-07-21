
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011200025522"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011200025522"
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
  name                = "acctestpip-230721011200025522"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011200025522"
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
  name                            = "acctestVM-230721011200025522"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5867!"
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
  name                         = "acctest-akcc-230721011200025522"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvdKhY2kXCjbm2uKzCtxVkHBAFgcfMBii+96ElxNZt4bmvQOYPljlEWPQzyCYXTxg/bvbWbwUbjqX1WsCcxATvtsmtCL43q/qmVZdS3Y1YLZMbTLMkY9LjwVDqLiap0qPZdpzsVUR4UTUgumJTdISqbJ0OG4/b+imu4YRKmPFvSwt/K1wUPSpoYsz1n/nDE3mlpZ8WM63xecnaWBvGbUS5Io9j2ux8v+05nJZ7EFrMGxyiFjWdRkzwHJofDzmdT23qys1p5qEfIysRLH7aSG/1vUkR+tKSWnG9YrfZ3yhWBWpdVq7XOnmocqj2dWSIKU06QXeMzrmmFaFw61rVlN8mGcdkLbp0PIzEVpgRR8RvfIzjM9AvdypttUFAbO2rKDt++rwBCfgVjwA9tORnXtdq5DnZeKG7fjQ2WlBjn5Ie3nRx8ChYZP73Xc1b84ps77vhd1LAwNmVnYZKbakfw3pO7p3XU3WGUwUy90U1I3+cVSwqZeAMOROu/nIBXN6+muZan9+c8ZWjmDNbgwGwYZtVBMrdg+JvskdTU4HM+qCORzTueQwUQF5A2bfEEY+YW9x5ug0glV14DcYr0ffI4LfMTNXhhH6Ce5hMYDu9X3Kusu38ztronTmIVZgtVVxnBSD0URcI4MCL5TFBXR3urPENz7H+QPC2d3yq4wcYwZHHF8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5867!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011200025522"
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
  name           = "acctest-kce-230721011200025522"
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
  name                     = "sa230721011200025522"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230721011200025522"
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

  start  = "2023-07-20T01:12:00Z"
  expiry = "2023-07-23T01:12:00Z"

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
  name       = "acctest-fc-230721011200025522"
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
