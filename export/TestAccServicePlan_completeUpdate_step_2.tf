
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211001020459780570"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-211001020459780570"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "P1v2"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  number_of_workers        = 3

  tags = {
    Foo = "bar"
  }
}
