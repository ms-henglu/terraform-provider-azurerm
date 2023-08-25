

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025056907321"
  location = "West Europe"
}


resource "azurerm_orbital_spacecraft" "test" {
  name                = "acctestspacecraft-230825025056907321"
  resource_group_name = azurerm_resource_group.test.name
  location            = "westus"
  norad_id            = "12345"

  links {
    bandwidth_mhz        = 100
    center_frequency_mhz = 101
    direction            = "Uplink"
    polarization         = "LHCP"
    name                 = "linkname"
  }

  two_line_elements = ["1 23455U 94089A   97320.90946019  .00000140  00000-0  10191-3 0  2621", "2 23455  99.0090 272.6745 0008546 223.1686 136.8816 14.11711747148495"]
  title_line        = "AQUA"
}
