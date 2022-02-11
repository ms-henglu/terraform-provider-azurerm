package backupinstances

type TriggerBackupRequest struct {
	BackupRuleOptions AdHocBackupRuleOptions `json:"backupRuleOptions"`
}
