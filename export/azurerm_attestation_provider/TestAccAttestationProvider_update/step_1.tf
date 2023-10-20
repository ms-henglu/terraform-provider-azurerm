
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-231020040533349389"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapu6s1o2iral"
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
