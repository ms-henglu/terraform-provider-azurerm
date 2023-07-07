
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005957506959"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005957506959"
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
  name                = "acctestpip-230707005957506959"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005957506959"
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
  name                            = "acctestVM-230707005957506959"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9484!"
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
  name                         = "acctest-akcc-230707005957506959"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArV64VEAwblc4DH9brINaaxe4zlF278y9qyjGuqpu9pk+9GcVaBb1OkYAbmZT/DnkLTogDd/GCh9FGHmPrmoHc6K6dgzHpZObGi1+2f1fRj+89NCes/EUUS2gga+RZqQDZ7Ta8Q4ck14weO9zznBzq0kgrJiEnf9K8TrpIRcM6E40QtKi8L1sO1grDvctQ9iEFLhTSbrDfGX5UwpancWSViMRXEVOyXEISWlLg+IuUJQSTankhb61GJLZHpbgbseWwj5BWehSdtmFB+C/wtKPH1meZ5dixa923n7i2yAo1tSZJ+Jrj9ux9fJqEofsdDJGqDu3sVrv8taFTQHMtRDcIxPkuj2NDLnw4+8aIza/kustyh1irgiQC0JZPNs9IEHVZmmAMTxJYguEqNfWRbvV0q7TK0j1/85Htf9Tacssy8qHCarDBIcYYTsWFEuz/PEjirU+lPwFehLL0DqQJNGm1ye8Hb7ulFN0enyegduQcfYpxbtY1t26tKAmkfLhmRUi0jxK6T66WACaThceWMbj9M10PttGSn216a3RtMuAe6VwVNqqHxgzMqgK2LV8Nhd5Zpd8zdsB4EYGDmQfw+QDQXvfKtVB6W47QkKPEYMcsGrVAaHX5gXUlpiVJhtLsgpziYEBXcedhXfJX3vvSGP3prKmFDc8+sK8c2FNihEIWpECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9484!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005957506959"
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
  name           = "acctest-kce-230707005957506959"
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
  name       = "acctest-fc-230707005957506959"
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
