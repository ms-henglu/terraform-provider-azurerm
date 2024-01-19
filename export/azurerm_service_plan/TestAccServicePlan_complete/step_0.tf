
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-240119024436496458"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-240119024436496458"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "P1v3"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  worker_count             = 3

  zone_balancing_enabled = true

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
