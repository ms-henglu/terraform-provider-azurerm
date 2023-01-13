
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181223274579"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-230113181223274579"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_dps_certificate" "test" {
  name                = "acctestIoTDPSCertificate-230113181223274579"
  resource_group_name = azurerm_resource_group.test.name
  iot_dps_name        = azurerm_iothub_dps.test.name

  certificate_content = filebase64("testdata/batch_certificate.cer")
}
