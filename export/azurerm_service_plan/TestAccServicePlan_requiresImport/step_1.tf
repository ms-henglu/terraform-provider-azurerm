


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-231020040506946547"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-231020040506946547"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "B1"
  os_type             = "Windows"

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}


resource "azurerm_service_plan" "import" {
  name                = azurerm_service_plan.test.name
  resource_group_name = azurerm_service_plan.test.resource_group_name
  location            = azurerm_service_plan.test.location
  sku_name            = azurerm_service_plan.test.sku_name
  os_type             = azurerm_service_plan.test.os_type
}
