
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_assessment_metadata" "test" {
  display_name = "Test Display Name"
  severity     = "Medium"
  description  = "Test Description"
}
