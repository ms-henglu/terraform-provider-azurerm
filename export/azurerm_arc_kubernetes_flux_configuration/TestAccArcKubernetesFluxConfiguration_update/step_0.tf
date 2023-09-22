
			
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053628096371"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053628096371"
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
  name                = "acctestpip-230922053628096371"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053628096371"
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
  name                            = "acctestVM-230922053628096371"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7159!"
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
  name                         = "acctest-akcc-230922053628096371"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyFrKa03/QWz7JafEXCRNYjh+RfAdbzwjTJ3nJfP2c39jT7pOFB2x724cVouC6QZ6heFt2yFvroGIWrjXBVGpVHruwg05IZQlQg378Y6G5kOqKuw7jkW0UymcYg09axPstirPGCFzti4ot0hqfrle5eRNoSIzyUHQ83snOe8ATdCaSNYNAbhOCZ5Md1+NeoLgn5uPY1MwNyHA/B47w+t0jyGpDhhiwGaeS2Z331g5s/sHoYNLZ3FQUkYfecsUD/eVnlOEKYQLLZdHTqXTwAPop9DK7t5epkJUneSADfIbsOzptcVrh53AWuN3trn9fFwZk+OD6AP8nZJO1Woo8qbNkZAc5oB4U/xmPwdk9USQ3Z+Cm0k3OYey49dyzLGW5KMS4ZglXw6AHM8mlT/4Y0nQILDbmZzinemrB7uzb+CuO5pmpUILQ3pcBsJ//Jpzs0lXnMJhibIr5ToXWfPuyLicttVE2Pc4jily0cA13BknpL/7NDqenaQ7y0gnPtwgFZB3YfAOF6pQ8tcftc80UYrw7Wfm3y1OPp2dLcVJ9l1MLLiN2V5gKCOQ2HCBOFAGaDCyrhf506OI2KeOaNHRSQuUzTA6Z/5m5fJCNJJzZk/K8o7kvzHMfQuM+C9zMNAed4nVMCDO+E1ytN2f5Ep35e7hE9/kenhOe/xZNRXJhp/sJgcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7159!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053628096371"
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
  name           = "acctest-kce-230922053628096371"
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
  name       = "acctest-fc-230922053628096371"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  bucket {
    access_key               = "example"
    secret_key_base64        = base64encode("example")
    bucket_name              = "flux"
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    url                      = "https://fluxminiotest.az.minio.io"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
