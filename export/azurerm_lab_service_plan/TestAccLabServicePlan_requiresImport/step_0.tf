

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lslp-230421022341297837"
  location = "West Europe"
}


resource "azurerm_lab_service_plan" "test" {
  name                = "acctest-lslp-230421022341297837"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allowed_regions     = [azurerm_resource_group.test.location]
}
