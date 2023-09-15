

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-elastic-230915023405015595"
  location = "West Europe"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-estc230915023405015595"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "terraform-acctest@hashicorp.com"
}


resource "azurerm_elastic_cloud_elasticsearch" "import" {
  name                        = azurerm_elastic_cloud_elasticsearch.test.name
  resource_group_name         = azurerm_elastic_cloud_elasticsearch.test.resource_group_name
  location                    = azurerm_elastic_cloud_elasticsearch.test.location
  sku_name                    = azurerm_elastic_cloud_elasticsearch.test.sku_name
  elastic_cloud_email_address = azurerm_elastic_cloud_elasticsearch.test.elastic_cloud_email_address
}
