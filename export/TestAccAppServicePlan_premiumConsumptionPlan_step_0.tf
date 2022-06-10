
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610023249875839"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220610023249875839"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "elastic"

  maximum_elastic_worker_count = 20

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}
