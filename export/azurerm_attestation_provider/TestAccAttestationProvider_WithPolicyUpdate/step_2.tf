

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230421021654408550"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapvr78pifx4c"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy {
    environment_type = "SgxEnclave"
    data             = "eyJhbGciOiJub25lIiwiamt1IjoiaHR0cHM6Ly94eHgudXMuYXR0ZXN0LmF6dXJlLm5ldC9jZXJ0cyIsImtpZCI6Inh4eCIsInR5cCI6IkpXVCJ9.eyJBdHRlc3RhdGlvblBvbGljeSI6ImRtVnljMmx2YmoweExqQTdDbUYxZEdodmNtbDZZWFJwYjI1eWRXeGxjd3A3Q2x0MGVYQmxQVDBpYzJWamRYSmxRbTl2ZEVWdVlXSnNaV1FpTENCMllXeDFaVDA5ZEhKMVpTd2dhWE56ZFdWeVBUMGlRWFIwWlhOMFlYUnBiMjVUWlhKMmFXTmxJbDA5UG5CbGNtMXBkQ2dwT3dwOU93b0thWE56ZFdGdVkyVnlkV3hsY3dwN0NqMC1JR2x6YzNWbEtIUjVjR1U5SWxObFkzVnlhWFI1VEdWMlpXeFdZV3gxWlNJc0lIWmhiSFZsUFRFd01DazdDbjA3In0."
  }
}
