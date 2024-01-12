
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240112224333462674"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240112224333462674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name                       = "acctestDatabricksLinkedService240112224333462674"
  data_factory_id            = azurerm_data_factory.test.id
  msi_work_space_resource_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/test/providers/Microsoft.Databricks/workspaces/testworkspace"

  description = "Initial description"
  annotations = ["test1", "test2"]
  adb_domain  = "https://adb-111111111.11.azuredatabricks.net"
  new_cluster_config {
    cluster_version       = "5.5.x-gpu-scala2.11"
    min_number_of_workers = 5
    node_type             = "Standard_NC12"
    driver_node_type      = "Standard_NC13"
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
