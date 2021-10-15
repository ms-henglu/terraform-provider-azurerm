
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014857376939"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211015014857376939"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  sms_receiver {
    name         = "oncallmsg"
    country_code = "1"
    phone_number = "1231231234"
  }
}
