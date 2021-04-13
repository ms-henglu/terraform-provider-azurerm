---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_user_rule"
description: |-
  Manages a network UserRule.
---

# azurerm_network_user_rule

Manages a network UserRule.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "examplesads"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_service_endpoint_policy" "example" {
  name = "example-serviceendpointpolicy"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_network_virtual_network" "example" {
  name = "example-virtualnetwork"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
}

resource "azurerm_network_group" "example" {
  name = "example-group"
  resource_group_name = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}

resource "azurerm_network_security_configuration" "example" {
  name = "example-securityconfiguration"
  resource_group_name = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}

resource "azurerm_network_user_rule" "example" {
  name = "example-userrule"
  resource_group_name = azurerm_resource_group.example.name
  configuration_name = azurerm_network_security_configuration.example.name
  network_manager_name = azurerm_network_manager.example.name
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this network UserRule. Changing this forces a new network UserRule to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the network UserRule should exist. Changing this forces a new network UserRule to be created.

* `configuration_name` - (Required) The name of the network manager security Configuration. Changing this forces a new network UserRule to be created.

* `network_manager_name` - (Required) The name of the network manager. Changing this forces a new network UserRule to be created.

---

* `description` - (Optional) A description for this rule. Restricted to 140 chars.

* `destination` - (Optional) A `destination` block as defined below.

* `destination_port_ranges` - (Optional) The destination port ranges.

* `direction` - (Optional) Indicates if the traffic matched against the rule in inbound or outbound. Possible values are "Inbound" and "Outbound" is allowed.

* `display_name` - (Optional) A friendly name for the rule.

* `protocol` - (Optional) Network protocol this rule applies to. Possible values are "Tcp", "Udp", "Icmp", "Esp", "Any" and "Ah" is allowed.

* `source` - (Optional) A `source` block as defined below.

* `source_port_ranges` - (Optional) The source port ranges.

---

An `destination` block exports the following:

* `address_prefix` - (Optional) Address prefix.

* `address_prefix_type` - (Optional) Address prefix type. Possible values are "IPPrefix" and "ServiceTag" is allowed.

---

An `source` block exports the following:

* `address_prefix` - (Optional) Address prefix.

* `address_prefix_type` - (Optional) Address prefix type. Possible values are "IPPrefix" and "ServiceTag" is allowed.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the network UserRule.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the network UserRule.
* `read` - (Defaults to 5 minutes) Used when retrieving the network UserRule.
* `delete` - (Defaults to 30 minutes) Used when deleting the network UserRule.

## Import

network UserRules can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_user_rule.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/configuration1/userRules/rule1
```