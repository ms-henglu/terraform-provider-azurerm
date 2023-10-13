
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231013042930978936"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapez4pm1fgtf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
      "sev_snp_policy_base64",
    ]
  }

  tags = {
    ENV = "Test"
  }
}
