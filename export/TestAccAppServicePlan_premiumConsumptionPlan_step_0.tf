
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015406762669"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-220726015406762669"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "elastic"

  maximum_elastic_worker_count = 20

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}
