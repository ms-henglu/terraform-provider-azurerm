
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cp-230818023817196643"
  location = "West Europe"
}
resource "azurerm_custom_provider" "test" {
  name                = "accTEst_saa230818023817196643"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  action {
    name     = "dEf2"
    endpoint = "https://example.com/"
  }
}
