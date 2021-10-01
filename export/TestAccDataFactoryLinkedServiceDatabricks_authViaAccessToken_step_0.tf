
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702324046"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211001020702324046"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name                = "acctestDatabricksLinkedService211001020702324046"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  access_token        = "SomeFakeAccessToken"
  description         = "Initial description"
  annotations         = ["test1", "test2"]
  adb_domain          = "https://adb-111111111.11.azuredatabricks.net"
  existing_cluster_id = "1234"
}
