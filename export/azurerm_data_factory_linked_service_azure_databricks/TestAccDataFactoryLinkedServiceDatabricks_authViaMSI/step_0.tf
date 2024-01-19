
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119021929372972"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119021929372972"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name                       = "acctestDatabricksLinkedService240119021929372972"
  data_factory_id            = azurerm_data_factory.test.id
  msi_work_space_resource_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/test/providers/Microsoft.Databricks/workspaces/testworkspace"

  description         = "Initial description"
  annotations         = ["test1", "test2"]
  existing_cluster_id = "test"
  adb_domain          = "https://adb-111111111.11.azuredatabricks.net"
}
