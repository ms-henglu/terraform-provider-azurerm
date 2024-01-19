
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025151955800"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-240119025151955800"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_dps_certificate" "test" {
  name                = "acctestIoTDPSCertificate-240119025151955800"
  resource_group_name = azurerm_resource_group.test.name
  iot_dps_name        = azurerm_iothub_dps.test.name
  is_verified         = true

  certificate_content = filebase64("testdata/batch_certificate.cer")
}
