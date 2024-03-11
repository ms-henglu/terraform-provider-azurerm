
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-240311032307923063"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240311032307923063"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  cloud_to_device {
    max_delivery_count = 20
    default_ttl        = "PT1H30M"
    feedback {
      time_to_live       = "PT1H15M"
      max_delivery_count = 25
      lock_duration      = "PT55S"
    }
  }

  tags = {
    purpose = "testing"
  }
}
