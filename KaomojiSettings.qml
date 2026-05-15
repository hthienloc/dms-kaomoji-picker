import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "kaomojiPicker"

    PluginHeader {
        title: "Kaomoji Picker Settings"
    }

    SettingsCard {
        SectionTitle { text: "General" }

        StringSetting {
            settingKey: "trigger"
            label: "Trigger Key"
            description: "The keyword to trigger this launcher (e.g. :kj)"
            placeholder: ":kj"
            defaultValue: ":kj"
        }

        SliderSetting {
            settingKey: "resultLimit"
            label: "Result Limit"
            description: "Maximum number of kaomoji to show in results."
            minimum: 10
            maximum: 200
            defaultValue: 50
        }

        ToggleSetting {
            settingKey: "enableHistory"
            label: "Enable History"
            description: "Show recently used kaomoji when the search is empty."
            defaultValue: true
        }

        SliderSetting {
            settingKey: "historyLimit"
            label: "History Size"
            description: "Number of recently used items to keep."
            minimum: 5
            maximum: 50
            defaultValue: 15
            visible: pluginData.enableHistory ?? true
        }
    }

    SettingsCard {
        SectionTitle { text: "Behavior" }

        ToggleSetting {
            settingKey: "showHints"
            label: "Show Hints"
            description: "Display usage tips in the launcher."
            defaultValue: true
        }
    }
}
