
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-elastic-220527034142699210"
  location = "West Europe"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-estc220527034142699210"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "terraform-acctest@hashicorp.com"
}
