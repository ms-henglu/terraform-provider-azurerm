
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231016033356549102"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbdr14bj3ec"
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
}
