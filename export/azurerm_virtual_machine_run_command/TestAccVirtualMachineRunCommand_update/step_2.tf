

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240119021734544234
}
variable "random_string" {
  default = "aoo20"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-vmcmd-${var.random_integer}"
  location = var.primary_location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-${var.random_integer}"
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

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-${var.random_integer}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-${var.random_integer}"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "Pa-${var.random_string}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc${var.random_string}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestsc${var.random_integer}"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "test1" {
  name                   = "script1"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_content         = "echo 'hello world'"
}

resource "azurerm_storage_blob" "test2" {
  name                   = "output"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Append"
}

resource "azurerm_storage_blob" "test3" {
  name                   = "error"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Append"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_virtual_machine_run_command" "test" {
  location           = azurerm_resource_group.test.location
  name               = "acctestvmrc-${var.random_string}"
  virtual_machine_id = azurerm_linux_virtual_machine.test.id
  run_as_password    = "Pa-${var.random_string}"
  run_as_user        = "adminuser"
  error_blob_uri     = azurerm_storage_blob.test3.id
  output_blob_uri    = azurerm_storage_blob.test2.id

  error_blob_managed_identity {
    client_id = azurerm_user_assigned_identity.test.client_id
  }

  output_blob_managed_identity {
    client_id = azurerm_user_assigned_identity.test.client_id
  }

  source {
    script_uri = azurerm_storage_blob.test1.id
    script_uri_managed_identity {
      client_id = azurerm_user_assigned_identity.test.client_id
    }
  }

  parameter {
    name  = "acctestvmrc-${var.random_string}"
    value = "val-${var.random_string}"
  }

  protected_parameter {
    name  = "acctestvmrc-${var.random_string}"
    value = "val-${var.random_string}"
  }

  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }

  depends_on = [
    azurerm_role_assignment.test,
  ]
}
