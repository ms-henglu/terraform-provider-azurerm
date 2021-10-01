
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestwebcert211001021342621696"
  location = "West Europe"
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctest211001021342621696"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = filebase64("testdata/app_service_certificate_nopassword.pfx")
}
