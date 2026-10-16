RegisterCommand('record', function()
    StartRecording(1)
    TriggerEvent('QBCore:Notify', locale('editor.started'), 'success')
end, false)

RegisterCommand('clip', function()
    StartRecording(0)
end, false)

RegisterCommand('saveclip', function()
    StopRecordingAndSaveClip()
    TriggerEvent('QBCore:Notify', locale('editor.save'), 'success')
end, false)

RegisterCommand('delclip', function()
    StopRecordingAndDiscardClip()
    TriggerEvent('QBCore:Notify', locale('editor.delete'), 'error')
end, false)

TriggerEvent('chat:addSuggestion', '/record', 'Start recording gameplay footage', {})
TriggerEvent('chat:addSuggestion', '/clip', 'Start recording a short clip', {})
TriggerEvent('chat:addSuggestion', '/saveclip', 'Save and stop the current clip', {})
TriggerEvent('chat:addSuggestion', '/deleteclip', 'Delete the current recording', {})

-- RegisterCommand('editor', function()
--     NetworkSessionLeaveSinglePlayer()
--     ActivateRockstarEditor()
--     TriggerEvent('QBCore:Notify', locale('editor.editor'), 'error')
-- end, false)
