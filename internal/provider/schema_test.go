package provider_test

import (
	"encoding/json"
	"fmt"
	"regexp"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-provider-azurerm/internal/provider"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func getRuleFromExistRules(name, desc string) *Rule {
	hardcases := []string{
		"azurerm_mysql_server.storage_profile",
		"azurerm_mysql_server.storage_profile.backup_retention_days",
		"azurerm_mysql_server.storage_profile.storage_mb",
		"azurerm_sentinel_alert_rule_ms_security_incident.text_whitelist",
		"azurerm_postgresql_server.storage_profile",
		"azurerm_postgresql_server.storage_profile.storage_mb",
		"azurerm_postgresql_server.storage_profile.backup_retention_days",
		"azurerm_postgresql_server.storage_profile.auto_grow",
		"azurerm_postgresql_server.storage_profile.geo_redundant_backup",
		"azurerm_mariadb_server.storage_profile",
		"azurerm_mariadb_server.storage_profile.backup_retention_days",
		"azurerm_mariadb_server.storage_profile.storage_mb",
	}
	if utils.SliceContainsValue(hardcases, name) {
		return &Rule{
			Name:   name,
			Target: "",
			Debug:  desc,
			Kind:   OtherDeprecation,
		}
	}
	// if rule exists return rule
	return nil
}

func getRuleIfRenamed(name, desc string) *Rule {
	r := regexp.MustCompile("`.*?`")
	if groups := r.FindStringSubmatch(desc); len(groups) == 1 {
		return &Rule{
			Name:   name,
			Target: groups[0],
			Debug:  desc,
			Kind:   RenameDeprecation,
		}
	}
	return nil
}

func getRuleIfRemoved(name, desc string) *Rule {
	r := regexp.MustCompile("`.*?`")
	if groups := r.FindStringSubmatch(desc); len(groups) == 0 {
		return &Rule{
			Name:   name,
			Target: "",
			Debug:  desc,
			Kind:   RemoveDeprecation,
		}
	}
	return nil
}

func dfs(resource *schema.Resource, prefix string) []Rule {
	results := make([]Rule, 0)
	if resource == nil {
		return results
	}
	for key, value := range resource.Schema {
		if len(value.Deprecated) > 0 {
			name := prefix + "." + key
			// 1. if this rule exists
			if rule := getRuleFromExistRules(name, value.Deprecated); rule != nil {
				results = append(results, *rule)
			} else
			// 2. try to find replaced prop
			if rule := getRuleIfRenamed(name, value.Deprecated); rule != nil {
				results = append(results, *rule)
			} else
			// 3. if this prop is removed
			if rule := getRuleIfRemoved(name, value.Deprecated); rule != nil {
				results = append(results, *rule)
			}
		}
		if value.Elem != nil {
			if subResource, ok := value.Elem.(*schema.Resource); ok {
				results = append(results, dfs(subResource, prefix+"."+key)...)
			}
		}
	}
	return results
}

func Test_DeprecatedProperties(t *testing.T) {
	azureProvider := provider.AzureProvider()
	rules := make([]Rule, 0)
	for key, value := range azureProvider.ResourcesMap {
		rules = append(rules, dfs(value, key)...)
	}

	for i := 0; i < len(rules); i++ {
		for j := 0; j < len(rules)-1; j++ {
			if rules[j].Kind < rules[j+1].Kind {
				rules[j], rules[j+1] = rules[j+1], rules[j]
			}
		}
	}

	j, _ := json.Marshal(rules)
	fmt.Printf("%v\n", string(j))

	autogen := ""
	for _, rule := range rules {
		if rule.Kind == RemoveDeprecation {
			autogen += fmt.Sprintf("\"%s\",\n", rule.Name)
		}
	}
	fmt.Println(autogen)
}

type DeprecationKind string

const (
	RenameDeprecation DeprecationKind = "Rename"
	RemoveDeprecation DeprecationKind = "Remove"
	OtherDeprecation  DeprecationKind = "Other"
)

type Rule struct {
	Name   string
	Target string
	Debug  string
	Kind   DeprecationKind
}
