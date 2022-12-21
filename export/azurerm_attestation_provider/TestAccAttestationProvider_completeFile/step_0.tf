

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221221203943633357"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaphzvg8ifivd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = file("testdata/cert.pem")

  tags = {
    ENV = "Test"
  }
}
