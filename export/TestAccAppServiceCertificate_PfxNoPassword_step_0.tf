
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestwebcert220527034834659079"
  location = "West Europe"
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctest220527034834659079"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = filebase64("testdata/app_service_certificate_nopassword.pfx")
}
