
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221216013416108183"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctkv9ht78"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "Delete", "List", "Purge", "Recover", "Set"]
  }
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-9ht78"
  value        = "password"
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet221216013416108183"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet221216013416108183"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test1" {
  name                = "acctpip1221216013416108183"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctpip1221216013416108183"
}

resource "azurerm_public_ip" "test2" {
  name                = "acctpip2221216013416108183"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctpip2221216013416108183"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa9ht78"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "setup-files"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}

resource "azurerm_storage_share" "test" {
  name                 = "sharename"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 30
}

data "azurerm_storage_account_blob_container_sas" "test" {
  connection_string = "${azurerm_storage_account.test.primary_connection_string}"
  container_name    = "${azurerm_storage_container.test.name}"
  https_only        = true

  start  = "2017-03-21"
  expiry = "2022-03-21"

  permissions {
    read   = true
    add    = false
    create = false
    write  = true
    delete = false
    list   = true
  }
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsql221216013416108183"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "${azurerm_resource_group.test.location}"
  version                      = "12.0"
  administrator_login          = "ssis_catalog_admin"
  administrator_login_password = "my-s3cret-p4ssword!"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm221216013416108183"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_linked_custom_service" "test" {
  name                 = "acctestls221216013416108183"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureBlobStorage"
  type_properties_json = <<JSON
{
  "connectionString": "${azurerm_storage_account.test.primary_connection_string}"
}
JSON
}

resource "azurerm_data_factory_linked_custom_service" "file_share_linked_service" {
  name                 = "acctestls1221216013416108183"
  data_factory_id      = azurerm_data_factory.test.id
  type                 = "AzureFileStorage"
  type_properties_json = <<JSON
{
  "host": "${azurerm_storage_share.test.url}",
  "password": {
    "type": "SecureString",
    "value": "${azurerm_storage_account.test.primary_access_key}"
  }
}
JSON
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "acctestlinkkv221216013416108183"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "test" {
  name            = "acctestSIRsh221216013416108183"
  data_factory_id = azurerm_data_factory.test.id
}

resource "azurerm_data_factory_integration_runtime_azure_ssis" "test" {
  name            = "acctestiras221216013416108183"
  description     = "acctest"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location

  node_size                        = "Standard_D8_v3"
  number_of_nodes                  = 2
  max_parallel_executions_per_node = 8
  edition                          = "Standard"
  license_type                     = "LicenseIncluded"

  vnet_integration {
    vnet_id     = "${azurerm_virtual_network.test.id}"
    subnet_name = "${azurerm_subnet.test.name}"
    public_ips  = [azurerm_public_ip.test1.id, azurerm_public_ip.test2.id]
  }

  catalog_info {
    server_endpoint        = "${azurerm_sql_server.test.fully_qualified_domain_name}"
    administrator_login    = "ssis_catalog_admin"
    administrator_password = "my-s3cret-p4ssword!"
    pricing_tier           = "Basic"
    dual_standby_pair_name = "dual_name"
  }

  custom_setup_script {
    blob_container_uri = "${azurerm_storage_account.test.primary_blob_endpoint}/${azurerm_storage_container.test.name}"
    sas_token          = "${data.azurerm_storage_account_blob_container_sas.test.sas}"
  }

  express_custom_setup {
    powershell_version = "6.2.0"

    environment = {
      Env = "test"
      Foo = "Bar"
    }

    component {
      name = "SentryOne.TaskFactory"
      key_vault_license {
        linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
        secret_name         = azurerm_key_vault_secret.test.name
        secret_version      = azurerm_key_vault_secret.test.version
        parameters = {
          "Env" : "Pro",
        }
      }
    }

    component {
      name = "oh22is.HEDDA.IO"
    }

    command_key {
      target_name = "name1"
      user_name   = "username1"
      key_vault_password {
        linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
        secret_name         = azurerm_key_vault_secret.test.name
        secret_version      = azurerm_key_vault_secret.test.version
        parameters = {
          "Env" : "Pro",
        }
      }
    }
  }

  package_store {
    name                = "store1"
    linked_service_name = azurerm_data_factory_linked_custom_service.file_share_linked_service.name
  }

  proxy {
    self_hosted_integration_runtime_name = azurerm_data_factory_integration_runtime_self_hosted.test.name
    staging_storage_linked_service_name  = azurerm_data_factory_linked_custom_service.test.name
    path                                 = "containerpath"
  }
}
