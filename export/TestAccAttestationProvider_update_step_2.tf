

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211015013908040589"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapscujx8jwtg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    ENV = "Test"
  }
}
