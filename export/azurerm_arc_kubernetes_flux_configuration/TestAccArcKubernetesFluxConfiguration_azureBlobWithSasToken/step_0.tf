
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042926191739"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042926191739"
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
  name                = "acctestpip-231013042926191739"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042926191739"
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
  name                            = "acctestVM-231013042926191739"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd782!"
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
  name                         = "acctest-akcc-231013042926191739"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz5hzW+J3zduLtxcd9a1BuiibI/FHDKetbW4CQF0fv6bdNkIrzR9iQ6d2eS3ImN6mEO8v9u19Mqpoa+CPR8YKEsnmyhTrwh4qnp3gNk8IKE/8kuad33FmxX2RByLW1Y40BxKTzYxSdk/jIEbDY68AzeImGtAFgqajKH8sWw1LXVLl4AXCfsJY0c9+xrZX9EISqf/jkTrg2HYBen7RaArlhYtuldutLPhH6HfqgZam8lJBSlby5AgkV3crHNcGM5GC+KBJjlGYfNSuCLivgSROzIQXI3k2IbHIMPiCoqnnwbDTDWALT6quUFiF9ML24Z8fZsHLdbfluxijYEJKxnPNUIHSDkOgLQ4yXDdMSnfPkehxhAgQkBtb2c3++AboSdN4ORHmesH7ZDKfb5E8IWaWVAHNHFJpv5x17BVwMK6S+y3q0eUmrPJd8biccLC8p1h7t6b8vN3BYEMZxSNJC0LyaJHcDkpVC9d64Fja2biHfFupQGor9EIw2+HNtxsrFBerbj3iauCFFCBo93TUN+Vj5N5eiy9nAZpiTOw+MZbSxOGYmdRYFsvvzQfW+ptniEeVCIxeAqBVlEAepIuLVq/1h6+KkQlZc55Ah9/n+nZ3QaxIQ/Tn+EtPjpmhjhr8xGICNq1nBm/za+4AwbL2pwQgmultG3vQKI88ZMH/n8eMNV8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd782!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042926191739"
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
  name           = "acctest-kce-231013042926191739"
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
  name                     = "sa231013042926191739"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231013042926191739"
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

  start  = "2023-10-12T04:29:26Z"
  expiry = "2023-10-15T04:29:26Z"

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
  name       = "acctest-fc-231013042926191739"
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
