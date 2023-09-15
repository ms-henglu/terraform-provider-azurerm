

provider "azurerm" {
  features {}
}

resource "azurerm_security_center_setting" "test" {
  setting_name = "MCAS"
  enabled      = "true"
}


resource "azurerm_security_center_setting" "import" {
  setting_name = azurerm_security_center_setting.test.setting_name
  enabled      = azurerm_security_center_setting.test.enabled
}
