
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230602030129020243"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapp31b947m7j"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  open_enclave_policy_base64 = "eyJhbGciOiJub25lIiwiamt1IjoiaHR0cHM6Ly9hY2N0ZXN0YXBwMzFiOTQ3bTdqLnVrcy5hdHRlc3QuYXp1cmUubmV0L2NlcnRzIiwia2lkIjoieHh4IiwidHlwIjoiSldUIn0.eyJBdHRlc3RhdGlvblBvbGljeSI6ImRtVnljMmx2YmoweExqQTdDbUYxZEdodmNtbDZZWFJwYjI1eWRXeGxjd3A3Q2x0MGVYQmxQVDBpYzJWamRYSmxRbTl2ZEVWdVlXSnNaV1FpTENCMllXeDFaVDA5ZEhKMVpTd2dhWE56ZFdWeVBUMGlRWFIwWlhOMFlYUnBiMjVUWlhKMmFXTmxJbDA5UG5CbGNtMXBkQ2dwT3dwOU93b0thWE56ZFdGdVkyVnlkV3hsY3dwN0NqMC1JR2x6YzNWbEtIUjVjR1U5SWxObFkzVnlhWFI1VEdWMlpXeFdZV3gxWlNJc0lIWmhiSFZsUFRFd01DazdDbjA3In0."
  sgx_enclave_policy_base64  = "eyJhbGciOiJub25lIiwiamt1IjoiaHR0cHM6Ly9hY2N0ZXN0YXBwMzFiOTQ3bTdqLnVrcy5hdHRlc3QuYXp1cmUubmV0L2NlcnRzIiwia2lkIjoieHh4IiwidHlwIjoiSldUIn0.eyJBdHRlc3RhdGlvblBvbGljeSI6ImRtVnljMmx2YmoweExqQTdDbUYxZEdodmNtbDZZWFJwYjI1eWRXeGxjd3A3Q2x0MGVYQmxQVDBpYzJWamRYSmxRbTl2ZEVWdVlXSnNaV1FpTENCMllXeDFaVDA5ZEhKMVpTd2dhWE56ZFdWeVBUMGlRWFIwWlhOMFlYUnBiMjVUWlhKMmFXTmxJbDA5UG5CbGNtMXBkQ2dwT3dwOU93b0thWE56ZFdGdVkyVnlkV3hsY3dwN0NqMC1JR2x6YzNWbEtIUjVjR1U5SWxObFkzVnlhWFI1VEdWMlpXeFdZV3gxWlNJc0lIWmhiSFZsUFRFd01DazdDbjA3In0."

  lifecycle {
    ignore_changes = [
      "tpm_policy_base64",
    ]
  }
}
