
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestwebcert220527034834653460"
  location = "West Europe"
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctest220527034834653460"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = filebase64("testdata/app_service_certificate.pfx")
  password            = "terraform"
}
