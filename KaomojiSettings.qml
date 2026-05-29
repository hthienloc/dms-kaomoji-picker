import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "./dms-common"

PluginSettings {
    id: root
    pluginId: "kaomojiPicker"

    SettingsCard {
        SectionTitle { text: I18n.tr("General"); icon: "settings" }

        StringSetting {
            settingKey: "trigger"
            label: I18n.tr("Trigger Key")
            description: I18n.tr("The keyword to trigger this launcher (e.g. kj)")
            placeholder: "kj"
            defaultValue: "kj"
        }

        SliderSetting {
            settingKey: "resultLimit"
            label: I18n.tr("Result Limit")
            description: I18n.tr("Maximum number of kaomoji to show in results.")
            minimum: 10
            maximum: 200
            defaultValue: 50
        }

        ToggleSetting {
            settingKey: "pasteOnSelect"
            label: I18n.tr("Paste on Select")
            description: I18n.tr("Directly paste the selected kaomoji into the active window.")
            defaultValue: true
        }

        ToggleSetting {
            settingKey: "enableHistory"
            label: I18n.tr("Enable History")
            description: I18n.tr("Show recently used kaomoji when the search is empty.")
            defaultValue: true
        }

        SliderSetting {
            settingKey: "historyLimit"
            label: I18n.tr("History Size")
            description: I18n.tr("Number of recently used items to keep.")
            minimum: 5
            maximum: 50
            defaultValue: 15
            visible: pluginData.enableHistory ?? true
        }
    }

    PluginAbout {
        repoUrl: "https://github.com/hthienloc/dms-kaomoji-picker"
    }
}
