function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "LimeAgentNotifier"
    $Toast.Group = "LimeAgentNotifier"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Lime Agent Notifier")
    $Notifier.Show($Toast);
}



try {
    $size = get-WmiObject win32_logicaldisk -filter "DriveType = '3'" | Select-Object -Property freespace,size
    $total_Size = [Math]::Round($size.size /1gb)
    $size_Left = [Math]::Round($size.freespace /1gb)

    if ($size_Left -lt ($total_Size / 10)) {
        Show-Notification -ToastTitle "Diskutrymme" -ToastText "You only have a small amount of diskspace left ($size_Left GB) available on your C: Drive. Your PC might not function correctly until some diskspace is freed"
    }
   
}
catch {

    Continue
}