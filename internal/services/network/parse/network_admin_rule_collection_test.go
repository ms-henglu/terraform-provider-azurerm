package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/resourceid"
)

var _ resourceid.Formatter = NetworkAdminRuleCollectionId{}

func TestNetworkAdminRuleCollectionIDFormatter(t *testing.T) {
	actual := NewNetworkAdminRuleCollectionID("12345678-1234-9876-4563-123456789012", "resGroup1", "networkManager1", "securityConfiguration1", "ruleCollection1").ID()
	expected := "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityAdminConfigurations/securityConfiguration1/ruleCollections/ruleCollection1"
	if actual != expected {
		t.Fatalf("Expected %q but got %q", expected, actual)
	}
}

func TestNetworkAdminRuleCollectionID(t *testing.T) {
	testData := []struct {
		Input    string
		Error    bool
		Expected *NetworkAdminRuleCollectionId
	}{

		{
			// empty
			Input: "",
			Error: true,
		},

		{
			// missing SubscriptionId
			Input: "/",
			Error: true,
		},

		{
			// missing value for SubscriptionId
			Input: "/subscriptions/",
			Error: true,
		},

		{
			// missing ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/",
			Error: true,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/",
			Error: true,
		},

		{
			// missing NetworkManagerName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/",
			Error: true,
		},

		{
			// missing value for NetworkManagerName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/",
			Error: true,
		},

		{
			// missing SecurityAdminConfigurationName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/",
			Error: true,
		},

		{
			// missing value for SecurityAdminConfigurationName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityAdminConfigurations/",
			Error: true,
		},

		{
			// missing RuleCollectionName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityAdminConfigurations/securityConfiguration1/",
			Error: true,
		},

		{
			// missing value for RuleCollectionName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityAdminConfigurations/securityConfiguration1/ruleCollections/",
			Error: true,
		},

		{
			// valid
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityAdminConfigurations/securityConfiguration1/ruleCollections/ruleCollection1",
			Expected: &NetworkAdminRuleCollectionId{
				SubscriptionId:                 "12345678-1234-9876-4563-123456789012",
				ResourceGroup:                  "resGroup1",
				NetworkManagerName:             "networkManager1",
				SecurityAdminConfigurationName: "securityConfiguration1",
				RuleCollectionName:             "ruleCollection1",
			},
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/12345678-1234-9876-4563-123456789012/RESOURCEGROUPS/RESGROUP1/PROVIDERS/MICROSOFT.NETWORK/NETWORKMANAGERS/NETWORKMANAGER1/SECURITYADMINCONFIGURATIONS/SECURITYCONFIGURATION1/RULECOLLECTIONS/RULECOLLECTION1",
			Error: true,
		},
	}

	for _, v := range testData {
		t.Logf("[DEBUG] Testing %q", v.Input)

		actual, err := NetworkAdminRuleCollectionID(v.Input)
		if err != nil {
			if v.Error {
				continue
			}

			t.Fatalf("Expect a value but got an error: %s", err)
		}
		if v.Error {
			t.Fatal("Expect an error but didn't get one")
		}

		if actual.SubscriptionId != v.Expected.SubscriptionId {
			t.Fatalf("Expected %q but got %q for SubscriptionId", v.Expected.SubscriptionId, actual.SubscriptionId)
		}
		if actual.ResourceGroup != v.Expected.ResourceGroup {
			t.Fatalf("Expected %q but got %q for ResourceGroup", v.Expected.ResourceGroup, actual.ResourceGroup)
		}
		if actual.NetworkManagerName != v.Expected.NetworkManagerName {
			t.Fatalf("Expected %q but got %q for NetworkManagerName", v.Expected.NetworkManagerName, actual.NetworkManagerName)
		}
		if actual.SecurityAdminConfigurationName != v.Expected.SecurityAdminConfigurationName {
			t.Fatalf("Expected %q but got %q for SecurityAdminConfigurationName", v.Expected.SecurityAdminConfigurationName, actual.SecurityAdminConfigurationName)
		}
		if actual.RuleCollectionName != v.Expected.RuleCollectionName {
			t.Fatalf("Expected %q but got %q for RuleCollectionName", v.Expected.RuleCollectionName, actual.RuleCollectionName)
		}
	}
}
