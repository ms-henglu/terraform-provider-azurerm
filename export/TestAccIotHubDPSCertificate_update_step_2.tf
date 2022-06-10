
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022656810730"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                = "acctestIoTDPS-220610022656810730"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_dps_certificate" "test" {
  name                = "acctestIoTDPSCertificate-220610022656810730"
  resource_group_name = azurerm_resource_group.test.name
  iot_dps_name        = azurerm_iothub_dps.test.name

  certificate_content = filebase64("testdata/application_gateway_test.cer")
}
