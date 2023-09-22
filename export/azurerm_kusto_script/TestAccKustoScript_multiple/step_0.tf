

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-kusto-230922061363"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc230922061363"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_kusto_database" "test" {
  name                = "acctestkd-230922061363"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa230922061363"
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


resource "azurerm_kusto_database" "test2" {
  name                = "acctest-kd-2-230922061321016063"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_kusto_database" "test3" {
  name                = "acctest-kd-3-230922061321016063"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_kusto_database" "test4" {
  name                = "acctest-kd-4-230922061321016063"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_name        = azurerm_kusto_cluster.test.name
}

resource "azurerm_kusto_script" "test" {
  name        = "acctest-ks-230922061321016063"
  database_id = azurerm_kusto_database.test.id
  url         = azurerm_storage_blob.test.id
  sas_token   = data.azurerm_storage_account_blob_container_sas.test.sas
}

resource "azurerm_kusto_script" "test2" {
  name        = "acctest-ks-2-230922061321016063"
  database_id = azurerm_kusto_database.test2.id
  url         = azurerm_storage_blob.test.id
  sas_token   = data.azurerm_storage_account_blob_container_sas.test.sas
}

resource "azurerm_kusto_script" "test3" {
  name        = "acctest-ks-3-230922061321016063"
  database_id = azurerm_kusto_database.test3.id
  url         = azurerm_storage_blob.test.id
  sas_token   = data.azurerm_storage_account_blob_container_sas.test.sas
}

resource "azurerm_kusto_script" "test4" {
  name        = "acctest-ks-4-230922061321016063"
  database_id = azurerm_kusto_database.test4.id
  url         = azurerm_storage_blob.test.id
  sas_token   = data.azurerm_storage_account_blob_container_sas.test.sas
}
