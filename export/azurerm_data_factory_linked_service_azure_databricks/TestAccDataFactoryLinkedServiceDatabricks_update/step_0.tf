
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759693282"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759693282"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name            = "acctestDatabricksLinkedService231016033759693282"
  data_factory_id = azurerm_data_factory.test.id
  description     = "Initial Description"
  annotations     = ["a1", "a2"]
  parameters = {
    key1 = "u1k1"
    key2 = "u1k2"
  }

  msi_work_space_resource_id = "/subscriptions/d111111-1111-1111-1111-111111111111/resourceGroups/Testing-rg-creation/providers/Microsoft.Databricks/workspaces/databricks-test"
  adb_domain                 = "https://someFakeDomain"

  new_cluster_config {
    node_type             = "Standard_NC12"
    cluster_version       = "5.5.x-gpu-scala2.11"
    min_number_of_workers = 3
    max_number_of_workers = 5
    driver_node_type      = "Standard_NC12"
    log_destination       = "dbfs:/logs"

    custom_tags = {
      sct1 = "sct_value_1"
      sct2 = "sct_value_2"
    }
    spark_config = {
      sc1 = "sc_value_1"
      sc2 = "sc_value_2"
    }
    spark_environment_variables = {
      sev1 = "sev_value_1"
      sev2 = "sev_value_2"
    }

    init_scripts = ["init.sh", "init2.sh"]
  }
}


