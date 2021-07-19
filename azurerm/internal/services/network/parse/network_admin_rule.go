package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
)

type NetworkAdminRuleId struct {
	SubscriptionId            string
	ResourceGroup             string
	NetworkManagerName        string
	SecurityConfigurationName string
	RuleCollectionName        string
	RuleName                  string
}

func NewNetworkAdminRuleID(subscriptionId, resourceGroup, networkManagerName, securityConfigurationName, ruleCollectionName, ruleName string) NetworkAdminRuleId {
	return NetworkAdminRuleId{
		SubscriptionId:            subscriptionId,
		ResourceGroup:             resourceGroup,
		NetworkManagerName:        networkManagerName,
		SecurityConfigurationName: securityConfigurationName,
		RuleCollectionName:        ruleCollectionName,
		RuleName:                  ruleName,
	}
}

func (id NetworkAdminRuleId) String() string {
	segments := []string{
		fmt.Sprintf("Rule Name %q", id.RuleName),
		fmt.Sprintf("Rule Collection Name %q", id.RuleCollectionName),
		fmt.Sprintf("Security Configuration Name %q", id.SecurityConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Admin Rule", segmentsStr)
}

func (id NetworkAdminRuleId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityConfigurations/%s/ruleCollections/%s/rules/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName, id.RuleCollectionName, id.RuleName)
}

// NetworkAdminRuleID parses a NetworkAdminRule ID into an NetworkAdminRuleId struct
func NetworkAdminRuleID(input string) (*NetworkAdminRuleId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkAdminRuleId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.NetworkManagerName, err = id.PopSegment("networkManagers"); err != nil {
		return nil, err
	}
	if resourceId.SecurityConfigurationName, err = id.PopSegment("securityConfigurations"); err != nil {
		return nil, err
	}
	if resourceId.RuleCollectionName, err = id.PopSegment("ruleCollections"); err != nil {
		return nil, err
	}
	if resourceId.RuleName, err = id.PopSegment("rules"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
