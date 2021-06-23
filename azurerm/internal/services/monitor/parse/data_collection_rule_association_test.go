package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/resourceid"
)

var _ resourceid.Formatter = DataCollectionRuleAssociationId{}

func TestDataCollectionRuleAssociationIDFormatter(t *testing.T) {
	actual := NewDataCollectionRuleAssociationID("703362b3-f278-4e4b-9179-c76eaf41ffc2", "group1", "virtualMachine1", "association1").ID()
	expected := "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/association1"
	if actual != expected {
		t.Fatalf("Expected %q but got %q", expected, actual)
	}
}

func TestDataCollectionRuleAssociationID(t *testing.T) {
	testData := []struct {
		Input    string
		Error    bool
		Expected *DataCollectionRuleAssociationId
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
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/",
			Error: true,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/",
			Error: true,
		},

		{
			// missing VirtualMachineName
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/",
			Error: true,
		},

		{
			// missing value for VirtualMachineName
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/",
			Error: true,
		},

		{
			// missing Name
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/",
			Error: true,
		},

		{
			// missing value for Name
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/",
			Error: true,
		},

		{
			// valid
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/association1",
			Expected: &DataCollectionRuleAssociationId{
				SubscriptionId:     "703362b3-f278-4e4b-9179-c76eaf41ffc2",
				ResourceGroup:      "group1",
				VirtualMachineName: "virtualMachine1",
				Name:               "association1",
			},
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/703362B3-F278-4E4B-9179-C76EAF41FFC2/RESOURCEGROUPS/GROUP1/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINES/VIRTUALMACHINE1/PROVIDERS/MICROSOFT.INSIGHTS/DATACOLLECTIONRULEASSOCIATIONS/ASSOCIATION1",
			Error: true,
		},
	}

	for _, v := range testData {
		t.Logf("[DEBUG] Testing %q", v.Input)

		actual, err := DataCollectionRuleAssociationID(v.Input)
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
		if actual.VirtualMachineName != v.Expected.VirtualMachineName {
			t.Fatalf("Expected %q but got %q for VirtualMachineName", v.Expected.VirtualMachineName, actual.VirtualMachineName)
		}
		if actual.Name != v.Expected.Name {
			t.Fatalf("Expected %q but got %q for Name", v.Expected.Name, actual.Name)
		}
	}
}
