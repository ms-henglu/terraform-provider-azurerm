package backupinstances

type AzureBackupRehydrationRequest struct {
	RecoveryPointId              string               `json:"recoveryPointId"`
	RehydrationPriority          *RehydrationPriority `json:"rehydrationPriority,omitempty"`
	RehydrationRetentionDuration string               `json:"rehydrationRetentionDuration"`
}
