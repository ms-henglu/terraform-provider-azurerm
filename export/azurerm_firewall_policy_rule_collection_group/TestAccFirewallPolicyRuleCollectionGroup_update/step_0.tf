
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fwpolicy-RCG-240315123101610786"
  location = "West Europe"
}
resource "azurerm_firewall_policy" "test" {
  name                = "acctest-fwpolicy-RCG-240315123101610786"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  dns {
    proxy_enabled = true
  }
}
resource "azurerm_ip_group" "test_source" {
  name                = "acctestIpGroupForFirewallPolicySource"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  cidrs               = ["1.2.3.4/32", "12.34.56.0/24"]
}
resource "azurerm_ip_group" "test_destination" {
  name                = "acctestIpGroupForFirewallPolicyDest"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  cidrs               = ["192.168.0.0/25", "192.168.0.192/26"]
}
resource "azurerm_firewall_policy_rule_collection_group" "test" {
  name               = "acctest-fwpolicy-RCG-240315123101610786"
  firewall_policy_id = azurerm_firewall_policy.test.id
  priority           = 500
  application_rule_collection {
    name     = "app_rule_collection1"
    priority = 500
    action   = "Deny"
    rule {
      name = "app_rule_collection1_rule1"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.0.1"]
      destination_fqdns = ["pluginsdk.io"]
    }
    rule {
      name = "app_rule_collection1_rule2"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups  = [azurerm_ip_group.test_source.id]
      destination_fqdns = ["pluginsdk.io"]
    }
    rule {
      name = "app_rule_collection1_rule3"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Mssql"
        port = 1443
      }
      source_addresses      = ["10.0.0.1"]
      destination_fqdn_tags = ["WindowsDiagnostics"]
    }
  }
  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 400
    action   = "Deny"
    rule {
      name                  = "network_rule_collection1_rule1"
      description           = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.1"]
      destination_addresses = ["192.168.1.1", "ApiManagement"]
      destination_ports     = ["80", "1000-2000"]
    }
    rule {
      name              = "network_rule_collection1_rule2"
      description       = "network_rule_collection1_rule2"
      protocols         = ["TCP", "UDP"]
      source_addresses  = ["10.0.0.1"]
      destination_fqdns = ["time.windows.com"]
      destination_ports = ["80", "1000-2000"]
    }
    rule {
      name                  = "network_rule_collection1_rule3"
      protocols             = ["TCP", "UDP"]
      source_ip_groups      = [azurerm_ip_group.test_source.id]
      destination_ip_groups = [azurerm_ip_group.test_destination.id]
      destination_ports     = ["80", "1000-2000"]
    }
    rule {
      name                  = "network_rule_collection1_rule4"
      protocols             = ["ICMP"]
      source_ip_groups      = [azurerm_ip_group.test_source.id]
      destination_ip_groups = [azurerm_ip_group.test_destination.id]
      destination_ports     = ["*"]
    }
  }
  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      description         = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.0.1", "10.0.0.2"]
      destination_address = "192.168.1.1"
      destination_ports   = ["80"]
      translated_address  = "192.168.0.1"
      translated_port     = "8080"
    }
    rule {
      name                = "nat_rule_collection1_rule2"
      protocols           = ["TCP", "UDP"]
      source_ip_groups    = [azurerm_ip_group.test_source.id]
      destination_address = "192.168.1.1"
      destination_ports   = ["80"]
      translated_address  = "192.168.0.1"
      translated_port     = "8080"
    }
    rule {
      name                = "nat_rule_collection1_rule3"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.0.1", "10.0.0.2"]
      destination_address = "192.168.1.1"
      destination_ports   = ["80"]
      translated_fqdn     = "time.microsoft.com"
      translated_port     = "8080"
    }
  }
}
