
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131313268083"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220627131313268083"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }
}

resource "azurerm_iothub_certificate" "test" {
  name                = "acctestIoTHubCertificate-220627131313268083"
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name

  certificate_content = filebase64("testdata/batch_certificate.cer")
}
