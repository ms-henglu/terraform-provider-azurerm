
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034251244346"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220527034251244346"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }
}

resource "azurerm_iothub_certificate" "test" {
  name                = "acctestIoTHubCertificate-220527034251244346"
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name

  certificate_content = filebase64("testdata/batch_certificate.cer")
}
