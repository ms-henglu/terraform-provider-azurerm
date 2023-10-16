

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lslp-231016034125815967"
  location = "West Europe"
}


resource "azurerm_lab_service_plan" "test" {
  name                = "acctest-lslp-231016034125815967"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allowed_regions     = [azurerm_resource_group.test.location]
}
