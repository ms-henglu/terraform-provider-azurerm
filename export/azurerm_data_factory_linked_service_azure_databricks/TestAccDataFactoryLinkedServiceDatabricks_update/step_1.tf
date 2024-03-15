
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824852083"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240315122824852083"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name            = "acctestDatabricksLinkedService240315122824852083"
  data_factory_id = azurerm_data_factory.test.id
  description     = "Updated Description"
  annotations     = ["b1", "b2"]
  parameters = {
    key1 = "u2k1"
    key2 = "u2k2"
  }
  msi_work_space_resource_id = "/subscriptions/d111111-1111-1111-1111-111111111111/resourceGroups/Testing-rg-creation/providers/Microsoft.Databricks/workspaces/databricks-test"
  adb_domain                 = "https://someFakedomain"

  new_cluster_config {
    node_type             = "Standard_NC20"
    cluster_version       = "6.5.x-gpu-scala2.11"
    min_number_of_workers = 5

    driver_node_type = "Standard_NC13"
    log_destination  = "dbfs:/logs_updated"

    custom_tags = {
      sct1 = "updated_sct_value_1"
      sct2 = "updated_sct_value_2"
    }
    spark_config = {
      sc1 = "updated_sc_value_1"
      sc2 = "updated_sc_value_2"
    }
    spark_environment_variables = {
      sev1 = "updated_sev_value_1"
      sev2 = "updated_sev_value_2"
    }

    init_scripts = ["updated_init.sh", "updated_init2.sh", "updated_init3.sh"]
  }
}


