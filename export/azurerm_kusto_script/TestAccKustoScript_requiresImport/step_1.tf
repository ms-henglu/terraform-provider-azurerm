


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-kusto-240119025244"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc240119025244"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-240119025244"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa240119025244"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "setup-files"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test" {
  name                   = "script.txt"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_content         = ".create table MyTable (Level:string, Timestamp:datetime, UserId:string, TraceId:string, Message:string, ProcessId:int32)"
}

data "azurerm_storage_account_blob_container_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  container_name    = azurerm_storage_container.test.name
  https_only        = true

  start  = "2022-03-21"
  expiry = "2027-03-21"

  permissions {
    read   = true
    add    = false
    create = false
    write  = true
    delete = false
    list   = true
  }
}


resource "azurerm_kusto_script" "test" {
  name        = "acctest-ks-240119025218628644"
  database_id = azurerm_kusto_database.test.id
  url         = azurerm_storage_blob.test.id
  sas_token   = data.azurerm_storage_account_blob_container_sas.test.sas
}


resource "azurerm_kusto_script" "import" {
  name        = azurerm_kusto_script.test.name
  database_id = azurerm_kusto_script.test.database_id
  url         = azurerm_kusto_script.test.url
  sas_token   = azurerm_kusto_script.test.sas_token
}
