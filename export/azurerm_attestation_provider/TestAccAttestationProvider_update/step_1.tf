
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230630032641087067"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgapdm1km4r"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
    ]
  }

  tags = {
    ENV = "Test"
  }
}
