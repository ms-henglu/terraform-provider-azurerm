


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lslp-240105060953839865"
  location = "West Europe"
}


resource "azurerm_lab_service_plan" "test" {
  name                = "acctest-lslp-240105060953839865"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allowed_regions     = [azurerm_resource_group.test.location]
}


resource "azurerm_lab_service_plan" "import" {
  name                = azurerm_lab_service_plan.test.name
  resource_group_name = azurerm_lab_service_plan.test.resource_group_name
  location            = azurerm_lab_service_plan.test.location
  allowed_regions     = azurerm_lab_service_plan.test.allowed_regions
}
