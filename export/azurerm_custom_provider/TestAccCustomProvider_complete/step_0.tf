
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-230512010501265655"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa230512010501265655"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  resource_type {
    name     = "dEf1"
    endpoint = "https://example.com/"
  }
}
