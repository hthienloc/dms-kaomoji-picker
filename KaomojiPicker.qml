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

    signal itemsChanged

    // Use Qt.resolvedUrl to get the path relative to this QML file's location.
    // This is the correct way to locate sibling files in a DMS plugin — pluginService
    // does not expose a pluginDir property.
    readonly property string dbPath: Qt.resolvedUrl("database.json").toString().replace("file://", "")

    FileView {
        id: loader
        path: ""
        watchChanges: false
        blockLoading: true
        // With blockLoading:true, the file is read synchronously when path is set.
        // We call loader.text() directly in init() rather than relying on onLoaded.
    }

    Component.onCompleted: {
        if (pluginService) {
            trigger = pluginService.loadPluginData("kaomojiPicker", "trigger", ":kj");
            init();
        }
    }

    onPluginServiceChanged: {
        if (pluginService) {
            trigger = pluginService.loadPluginData("kaomojiPicker", "trigger", ":kj");
            init();
        }
    }

    function init() {
        if (dbLoading || dbLoaded) return;
        dbLoading = true;

        console.log("KaomojiPicker: Loading from " + dbPath);
        loader.path = dbPath;

        // blockLoading:true means file is fully read by the time we reach here
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

    function getItems(query) {
        if (dbLoading) {
            return [{
                name: "Loading database...",
                comment: "Please wait, parsing ~10MB of kaomoji",
                icon: "unicode:\u2800",
                executable: false
            }];
        }

        if (!dbLoaded) {
            if (pluginService) init();
            return [{
                name: "Initializing...",
                comment: "Kaomoji database is starting up",
                icon: "unicode:\u2800",
                executable: false
            }];
        }

        let items = [];
        const lowerQuery = query.toLowerCase().trim();

        for (const key in database) {
            const entry = database[key];
            const newTags = Array.isArray(entry.new_tags) ? entry.new_tags : [];
            const oldTags = Array.isArray(entry.original_tags) ? entry.original_tags : [];
            const tags = newTags.concat(oldTags).join(", ");

            if (lowerQuery === "" || tags.toLowerCase().includes(lowerQuery)) {
                items.push({
                    name: key,
                    comment: tags,
                    // Invisible Braille Blank (U+2800): if icon is "" DMS falls back to
                    // rendering the first character of `name` — which is the kaomoji itself.
                    // Using an invisible unicode character prevents this unwanted fallback.
                    icon: "unicode:\u2800",
                    executable: true,
                    _kaomoji: key
                });
            }

            if (items.length >= 50) break;
        }

        return items;
    }

    function executeItem(item) {
        if (!item || !item._kaomoji) return;

        const kaomoji = item._kaomoji;
        const cmd = "if command -v dms >/dev/null 2>&1; then printf '%s' \"$1\" | setsid dms cl copy; else printf '%s' \"$1\" | wl-copy; fi";
        Quickshell.execDetached(["sh", "-c", cmd, "copy", kaomoji]);
    }
}
