
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301705274"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230915023301705274"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name                = "acctestDatabricksLinkedService230915023301705274"
  data_factory_id     = azurerm_data_factory.test.id
  access_token        = "SomeFakeAccessToken"
  description         = "Initial description"
  annotations         = ["test1", "test2"]
  adb_domain          = "https://adb-111111111.11.azuredatabricks.net"
  existing_cluster_id = "1234"
}
