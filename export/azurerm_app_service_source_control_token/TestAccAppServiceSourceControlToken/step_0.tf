
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "c1rcuqeg3auzr7aj9t78o000qbyhrenuconlzno4d"
  token_secret = "01g97cksqspzbgydljxcyp7v01ikeqvih4xcyjw2n"
}
