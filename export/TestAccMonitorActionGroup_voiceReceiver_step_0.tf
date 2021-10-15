
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014525557602"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211015014525557602"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  voice_receiver {
    name         = "oncallmsg"
    country_code = "1"
    phone_number = "1231231234"
  }
}
