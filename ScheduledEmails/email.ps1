function SendAlertEmail($Body){

$From = "tate.morris@mymail.champlain.edu"
$To = "tate.morris@mymail.champlain.edu"
$Subject = "Suspicious Activity"

$Password = "zyxq gstp nqwi vjvx" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential

}

SendAlertEmail "Body of email"