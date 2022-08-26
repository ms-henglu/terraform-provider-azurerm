
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-220826002540498728"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa220826002540498728"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  resource_type {
    name     = "dEf1"
    endpoint = "https://example.com/"
  }
}
