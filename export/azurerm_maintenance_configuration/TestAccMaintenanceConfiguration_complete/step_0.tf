
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-240119025325201319"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC240119025325201319"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "SQLDB"
  visibility          = "Custom"

  window {
    start_date_time      = "5555-12-31 00:00"
    expiration_date_time = "6666-12-31 00:00"
    duration             = "06:00"
    time_zone            = "Pacific Standard Time"
    recur_every          = "2Days"
  }

  properties = {
    description = "acceptance test"
  }

  tags = {
    enV = "TesT"
  }
}
