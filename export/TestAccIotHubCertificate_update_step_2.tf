
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004529109261"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220715004529109261"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_certificate" "test" {
  name                = "acctestIoTCertificate-220715004529109261"
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name
  is_verified         = true

  certificate_content = filebase64("testdata/application_gateway_test.cer")
}
