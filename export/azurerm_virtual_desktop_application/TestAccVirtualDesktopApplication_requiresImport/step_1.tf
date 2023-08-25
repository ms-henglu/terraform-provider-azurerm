

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230825024436698979"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                = "acctestHP"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "test" {
  name                = "acctestAG23082579"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  type                = "RemoteApp"
  host_pool_id        = azurerm_virtual_desktop_host_pool.test.id
}

resource "azurerm_virtual_desktop_application" "test" {
  name                         = "acctestAG23082579"
  application_group_id         = azurerm_virtual_desktop_application_group.test.id
  path                         = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
  command_line_argument_policy = "DoNotAllow"
}


resource "azurerm_virtual_desktop_application" "import" {
  name                         = azurerm_virtual_desktop_application.test.name
  application_group_id         = azurerm_virtual_desktop_application.test.application_group_id
  path                         = azurerm_virtual_desktop_application.test.path
  command_line_argument_policy = azurerm_virtual_desktop_application.test.command_line_argument_policy

}
