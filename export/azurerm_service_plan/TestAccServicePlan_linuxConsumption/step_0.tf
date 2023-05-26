
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-230526084548620024"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-230526084548620024"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Y1"
  os_type             = "Linux"

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
