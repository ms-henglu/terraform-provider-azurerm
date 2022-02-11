package backupinstances

type AdHocBackupRuleOptions struct {
	RuleName      string                   `json:"ruleName"`
	TriggerOption AdhocBackupTriggerOption `json:"triggerOption"`
}
