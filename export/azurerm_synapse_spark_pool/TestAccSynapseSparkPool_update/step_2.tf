

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240105064745822001"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchme0k"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240105064745822001"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw240105064745822001"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_synapse_spark_pool" "test" {
  name                                = "acctestSSPhme0k"
  synapse_workspace_id                = azurerm_synapse_workspace.test.id
  node_size_family                    = "MemoryOptimized"
  node_size                           = "Medium"
  dynamic_executor_allocation_enabled = true
  min_executors                       = 1
  max_executors                       = 3
  session_level_packages_enabled      = true
  cache_size                          = 100
  auto_pause {
    delay_in_minutes = 15
  }

  auto_scale {
    max_node_count = 50
    min_node_count = 3
  }

  library_requirement {
    content  = <<EOF
appnope==0.1.0
beautifulsoup4==4.6.3
EOF
    filename = "requirements.txt"
  }

  spark_config {
    content  = <<EOF
spark.shuffle.spill                true
EOF
    filename = "config.txt"
  }

  spark_log_folder    = "/logs"
  spark_events_folder = "/events"
  spark_version       = "2.4"

  tags = {
    ENV = "Test"
  }
}
