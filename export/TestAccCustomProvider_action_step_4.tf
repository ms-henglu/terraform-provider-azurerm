
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-211210024444863769"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa211210024444863769"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  action {
    name     = "dEf1"
    endpoint = "https://example.com/"
  }
}
