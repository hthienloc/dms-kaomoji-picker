import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
import "../dms-common"

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

    // Config state
    property int resultLimit: 50
    property bool enableHistory: true
    property int historyLimit: 15

    signal itemsChanged

    readonly property string dbPath: Qt.resolvedUrl("database.json").toString().replace("file://", "")

    function updateConfigs() {
        if (!pluginService) return;
        trigger = pluginService.loadPluginData("kaomojiPicker", "trigger", ":kj");
        resultLimit = pluginService.loadPluginData("kaomojiPicker", "resultLimit", 50);
        enableHistory = pluginService.loadPluginData("kaomojiPicker", "enableHistory", true);
        historyLimit = pluginService.loadPluginData("kaomojiPicker", "historyLimit", 15);
        console.log("KaomojiPicker: Configs updated (History: " + enableHistory + ")");
    }

    Connections {
        target: pluginService
        function onPluginDataChanged(id) {
            if (id === "kaomojiPicker") updateConfigs();
        }
        function onPluginStateChanged(id) {
            if (id === "kaomojiPicker") loadHistory();
        }
    }

    FileView {
        id: loader
        path: ""
        watchChanges: false
        blockLoading: true
    }

    Component.onCompleted: {
        if (pluginService) {
            updateConfigs();
            loadHistory();
            init();
        }
    }

    onPluginServiceChanged: {
        if (pluginService) {
            updateConfigs();
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
        const loaded = pluginService.loadPluginState("kaomojiPicker", "history", []);
        history = Array.isArray(loaded) ? loaded : [];
        console.log("KaomojiPicker: History loaded, count: " + history.length);
        itemsChanged();
    }

    function saveToHistory(kaomoji) {
        if (!pluginService || !enableHistory) return;
        
        let list = history.slice();
        let idx = list.indexOf(kaomoji);
        if (idx >= 0) list.splice(idx, 1);
        list.unshift(kaomoji);
        if (list.length > historyLimit) list = list.slice(0, historyLimit);
        
        history = list;
        pluginService.savePluginState("kaomojiPicker", "history", list);
        console.log("KaomojiPicker: Saved to history: " + kaomoji);
        itemsChanged(); // Force immediate UI refresh
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

        // 1. Process History (Always prioritized newest to oldest)
        let matchingHistory = [];
        if (enableHistory && history.length > 0) {
            history.forEach((k, index) => {
                let match = false;
                if (lowerQuery === "") {
                    match = true;
                } else {
                    if (k.toLowerCase().includes(lowerQuery)) {
                        match = true;
                    } else {
                        const entry = database[k];
                        if (entry) {
                            const tags = (Array.isArray(entry.new_tags) ? entry.new_tags : [])
                                         .concat(Array.isArray(entry.original_tags) ? entry.original_tags : [])
                                         .join(", ").toLowerCase();
                            if (tags.includes(lowerQuery)) match = true;
                        }
                    }
                }

                if (match) {
                    matchingHistory.push({
                        name: k,
                        icon: "material:history",
                        executable: true,
                        _kaomoji: k,
                        _preScored: 2000 - index // High score, preserves newest-first order
                    });
                }
            });
        }

        if (lowerQuery === "") {
            return matchingHistory;
        }

        // 2. Add history matches first
        items = matchingHistory;

        // 3. Search Database for remaining results
        const limit = root.resultLimit;
        let dbMatchCount = 0;
        
        for (const key in database) {
            if (items.length >= limit) break;
            
            // Skip if already in history list (avoid duplicates)
            if (items.some(i => i._kaomoji === key)) continue;

            const entry = database[key];
            const tags = (Array.isArray(entry.new_tags) ? entry.new_tags : [])
                         .concat(Array.isArray(entry.original_tags) ? entry.original_tags : [])
                         .join(", ");

            if (tags.toLowerCase().includes(lowerQuery) || key.toLowerCase().includes(lowerQuery)) {
                items.push({
                    name: key,
                    comment: tags,
                    icon: "unicode:\u2800",
                    executable: true,
                    _kaomoji: key,
                    _preScored: 1000 - dbMatchCount // Lower score than history, but preserves DB order
                });
                dbMatchCount++;
            }
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
