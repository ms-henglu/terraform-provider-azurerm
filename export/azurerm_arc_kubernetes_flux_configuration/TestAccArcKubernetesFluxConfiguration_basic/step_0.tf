
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031756669739"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031756669739"
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
  name                = "acctestpip-230728031756669739"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031756669739"
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
  name                            = "acctestVM-230728031756669739"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7695!"
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
  name                         = "acctest-akcc-230728031756669739"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArHp3thelwST4AHmY1f7f4HE15DRoLSazjxFfrlIMzkhc1WxS15cZBBJEx8tPrZB1ZnyhH+cB7uwImj+LFpNeBtmW8iHkYoxjqdJ3fhy+KoU3WfqK4WkxYGiNL04/qugOvAaoJAKZU7EJh5esC+A5gaGJD0KaYcDDBqCZiQLsuzcj3Q2igEX+71+UXBO/objFPpsRfDdLFwneLoHIG+hGXmc5qgK0321sZzIJFeVTrUjDelqMv2y1FFacpcOX+1rgTl7A3LQ8+vEG6A/Hz1/dupTtP9Ij+sadnmny6C0ink50rHHmjHLpAVfrXt70m6E9ZFK8QCzj+BPDO6C/eheYLYcppHpv2kB0eJ/QvYLO74PgLYcubj7Hptc+GbvBDKVhy7U3N/ehEr/9MMVS5hVLjEjEK10dbTVnh+x3gPKzjpv0Y0hSFsWreoRqJVgnunCVQWQhB6qACGG2FIykfEPBx3GCFL7ipPUTr5ob5529E1KOuITbUtAJI9VIy0yKUTeBUpv1vE+/kxnMgFH+cuEqyacvTQ67KTCE0ssdyTxE71uHrlvVZqA6ht6ZmsUIk+ZQbYMJOmTn42QSiKHBql0gwN3xokBhJicspVyznueHlEw8Wb6uvpKQKZ16f7w4+zsHRBynsoh/IYP1+io3KPoP7cUQ0SOtZsKPh4+/PIp1X48CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7695!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031756669739"
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
  name           = "acctest-kce-230728031756669739"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230728031756669739"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
