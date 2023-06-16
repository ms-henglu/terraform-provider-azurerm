

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230616074242319826"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1wj9of7afs"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
    ]
  }
}


resource "azurerm_attestation_provider" "import" {
  name                = azurerm_attestation_provider.test.name
  resource_group_name = azurerm_attestation_provider.test.resource_group_name
  location            = azurerm_attestation_provider.test.location

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
    ]
  }
}
