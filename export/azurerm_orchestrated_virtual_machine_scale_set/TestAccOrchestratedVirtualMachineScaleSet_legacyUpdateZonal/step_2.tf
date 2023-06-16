

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-OVMSS-230616074443128506"
  location = "West Europe"
}


resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestOVMSS-230616074443128506"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  platform_fault_domain_count = 1

  zones = ["1"]

  tags = {
    ENV = "Test",
    FOO = "Bar"
  }
}
