
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-230512010501267315"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa230512010501267315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  action {
    name     = "dEf1"
    endpoint = "https://example.com/"
  }
}
