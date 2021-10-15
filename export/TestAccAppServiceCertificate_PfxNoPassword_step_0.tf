
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestwebcert211015015256042719"
  location = "West Europe"
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctest211015015256042719"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = filebase64("testdata/app_service_certificate_nopassword.pfx")
}
