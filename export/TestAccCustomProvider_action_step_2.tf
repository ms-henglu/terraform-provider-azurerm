
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-220826002540498830"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa220826002540498830"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  action {
    name     = "dEf2"
    endpoint = "https://example.com/"
  }
}
