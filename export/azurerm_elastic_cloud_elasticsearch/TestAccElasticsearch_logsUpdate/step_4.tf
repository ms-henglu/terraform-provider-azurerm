
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-elastic-240119025013375163"
  location = "West Europe"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-estc240119025013375163"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "terraform-acctest@hashicorp.com"
}
