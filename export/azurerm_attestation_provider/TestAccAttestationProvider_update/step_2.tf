

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230324051628528316"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapzl9mbhru2o"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    ENV = "Test"
  }
}
