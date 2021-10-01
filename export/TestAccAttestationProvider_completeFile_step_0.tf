

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001053444064493"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap2ukc3m7zpl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = file("testdata/cert.pem")

  tags = {
    ENV = "Test"
  }
}
