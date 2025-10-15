. "C:\Users\User\LinuxClass\SYS-320\week6\LocalUserManagement\Event-Logs.ps1"
. "C:\Users\User\LinuxClass\SYS-320\ScheduledEmails\email.ps1"
. "C:\Users\User\LinuxClass\SYS-320\ScheduledEmails\scheduler.ps1"
. "C:\Users\User\LinuxClass\SYS-320\ScheduledEmails\configuration.ps1"

#Obtain configuration
$configuration = readConfiguration

# 2) Obtain at-risk users
$Failed = getFailedLogins -timeBack $configuration.Days

# 3) Send at-risk users as an email
SendAlertEmail ($Failed | Format-Table -AutoSize | Out-String)

# 4) Register the daily task at the configured time
ChooseTimeToRun ($configuration.SendTime)