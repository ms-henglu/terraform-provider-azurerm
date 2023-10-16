
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034326076525"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231016034326076525"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  sms_receiver {
    name         = "oncallmsg"
    country_code = "1"
    phone_number = "2123456789"
  }
}
