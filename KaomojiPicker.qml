import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Item {
    id: root

    property var pluginService: null
    property string trigger: ":kj"

    // Database state
    property var database: ({})
    property bool dbLoaded: false
    property bool dbLoading: false
    
    // History state
    property var history: []

    // Config from settings
    readonly property int resultLimit: pluginService?.loadPluginData("kaomojiPicker", "resultLimit", 50) || 50
    readonly property bool enableHistory: pluginService?.loadPluginData("kaomojiPicker", "enableHistory", true) ?? true
    readonly property int historyLimit: pluginService?.loadPluginData("kaomojiPicker", "historyLimit", 15) || 15
    readonly property bool showHints: pluginService?.loadPluginData("kaomojiPicker", "showHints", true) ?? true

    signal itemsChanged

    readonly property string dbPath: Qt.resolvedUrl("database.json").toString().replace("file://", "")

    FileView {
        id: loader
        path: ""
        watchChanges: false
        blockLoading: true
    }

    Component.onCompleted: {
        if (pluginService) {
            trigger = pluginService.loadPluginData("kaomojiPicker", "trigger", ":kj");
            loadHistory();
            init();
        }
    }

    onPluginServiceChanged: {
        if (pluginService) {
            trigger = pluginService.loadPluginData("kaomojiPicker", "trigger", ":kj");
            loadHistory();
            init();
        }
    }

    function init() {
        if (dbLoading || dbLoaded) return;
        dbLoading = true;

        console.log("KaomojiPicker: Loading from " + dbPath);
        loader.path = dbPath;

        const rawText = loader.text();
        if (!rawText || rawText.length < 2) {
            console.error("KaomojiPicker: File empty or not found at: " + dbPath);
            dbLoading = false;
            return;
        }

        try {
            database = JSON.parse(rawText);
            dbLoaded = true;
            dbLoading = false;
            console.log("KaomojiPicker: Loaded " + Object.keys(database).length + " entries.");
            itemsChanged();
        } catch (e) {
            console.error("KaomojiPicker: JSON parse failed: " + e);
            dbLoading = false;
        }
    }

    function loadHistory() {
        if (!pluginService) return;
        history = pluginService.loadPluginState("kaomojiPicker", "history", []);
    }

    function saveToHistory(kaomoji) {
        if (!pluginService || !enableHistory) return;
        
        let list = history.slice();
        // Remove if already exists to move to top
        let idx = list.indexOf(kaomoji);
        if (idx >= 0) list.splice(idx, 1);
        
        // Add to top
        list.unshift(kaomoji);
        
        // Trim
        if (list.length > historyLimit) list = list.slice(0, historyLimit);
        
        history = list;
        pluginService.savePluginState("kaomojiPicker", "history", list);
    }

    function getItems(query) {
        if (dbLoading) {
            return [{
                name: "Loading database...",
                comment: "Please wait, parsing ~10MB of kaomoji",
                icon: "material:sync",
                executable: false
            }];
        }

        if (!dbLoaded) {
            if (pluginService) init();
            return [{
                name: "Initializing...",
                comment: "Kaomoji database is starting up",
                icon: "material:hourglass_empty",
                executable: false
            }];
        }

        let items = [];
        const lowerQuery = query.toLowerCase().trim();

        // 1. Show History if query is empty
        if (lowerQuery === "" && enableHistory && history.length > 0) {
            history.forEach(k => {
                items.push({
                    name: k,
                    comment: "Recently used",
                    icon: "material:history",
                    executable: true,
                    _kaomoji: k
                });
            });
            
            if (items.length > 0) {
                items.unshift({
                    name: "Recently Used",
                    icon: "material:star",
                    executable: false,
                    categories: ["Header"]
                });
            }
        }

        // 2. Search Database
        const limit = root.resultLimit;
        let count = 0;
        
        for (const key in database) {
            const entry = database[key];
            const newTags = Array.isArray(entry.new_tags) ? entry.new_tags : [];
            const oldTags = Array.isArray(entry.original_tags) ? entry.original_tags : [];
            const tags = newTags.concat(oldTags).join(", ");

            if (lowerQuery === "" || tags.toLowerCase().includes(lowerQuery) || key.toLowerCase().includes(lowerQuery)) {
                // Avoid duplicates with history
                if (lowerQuery === "" && items.some(i => i._kaomoji === key)) continue;

                items.push({
                    name: key,
                    comment: tags,
                    icon: "unicode:\u2800",
                    executable: true,
                    _kaomoji: key
                });
                count++;
            }

            if (count >= limit) break;
        }

        return items;
    }

    function executeItem(item) {
        if (!item || !item._kaomoji) return;

        const kaomoji = item._kaomoji;
        
        // Save to history
        saveToHistory(kaomoji);
        
        // Native DMS clipboard copy
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | setsid dms cl copy", "copy", kaomoji]);
        
        // Feedback
        ToastService?.showInfo("Copied to clipboard: " + kaomoji);
    }
}
