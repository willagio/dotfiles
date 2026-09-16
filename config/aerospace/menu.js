ObjC.import('AppKit');

function run() {
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    function quote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }
    function command(args) {
        return app.doShellScript(args.map(quote).join(' ')).trim();
    }
    function title(value) {
        // SwiftBar treats pipes and newlines as menu syntax.
        return String(value).replace(/[\x00-\x1f\x7f|]/g, ' ').trim();
    }

    const home = app.pathTo('home folder').toString();
    const state = JSON.parse(command([
        'osascript', '-l', 'JavaScript', home + '/dotfiles/config/aerospace/cycle-stack.js', 'list'
    ]));
    if (state.windows.length < 2) return '';

    const aerospacePath = app.doShellScript('command -v aerospace').trim();
    const font = $.NSFont.systemFontOfSize(13);
    const activeFont = $.NSFont.boldSystemFontOfSize(13);
    const labels = state.windows.map(window => {
        let label = title(window['app-name']);
        const sameApp = state.windows.filter(other => other['app-name'] === window['app-name']).length > 1;
        const windowTitle = title(window['window-title']);
        if (sameApp && windowTitle) label += ' — ' + windowTitle;
        return label;
    });
    const gap = Math.min(8, 90 / labels.length);
    const maxLabelWidth = (180 - gap * (labels.length - 1)) / labels.length;
    // Reserve both font widths so changing focus never moves the labels.
    const labelWidths = labels.map(label => Math.min(maxLabelWidth, Math.ceil(Math.max(
        $(label).sizeWithAttributes($({NSFont: font})).width,
        $(label).sizeWithAttributes($({NSFont: activeFont})).width
    ))));
    const width = Math.ceil(labelWidths.reduce((sum, value) => sum + value, 0) + gap * (labels.length - 1));
    const height = 20;
    const image = $.NSImage.alloc.initWithSize({width, height});
    const paragraph = $.NSMutableParagraphStyle.alloc.init;
    paragraph.lineBreakMode = $.NSLineBreakByTruncatingTail;
    paragraph.alignment = $.NSTextAlignmentLeft;
    function draw(label, x, cellWidth, active) {
        $(label).drawInRectWithAttributes(
            {origin: {x, y: 2}, size: {width: cellWidth, height: 18}},
            $({NSFont: active ? activeFont : font,
                NSColor: $.NSColor.blackColor, NSParagraphStyle: paragraph})
        );
    }
    image.lockFocus;
    let x = 0;
    state.windows.forEach((window, index) => {
        draw(labels[index], x, labelWidths[index], window['window-id'] === state.focusedId);
        x += labelWidths[index] + gap;
    });
    image.unlockFocus;
    const bitmap = $.NSBitmapImageRep.imageRepWithData(image.TIFFRepresentation);
    const png = bitmap.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $({}));
    const encoded = ObjC.unwrap(png.base64EncodedStringWithOptions(0));
    const lines = ['| templateImage=' + encoded + ' width=' + width + ' height=' + height + ' dropdown=false', '---'];
    for (const window of state.windows) {
        const windowTitle = title(window['window-title']);
        const label = title(window['app-name']) + (windowTitle ? ' — ' + windowTitle : '');
        lines.push(label + ' | length=70 checked=' + (window['window-id'] === state.focusedId)
            + ' bash=' + quote(aerospacePath)
            + ' param1=focus param2=--window-id param3=' + window['window-id']
            + ' terminal=false refresh=true');
    }
    return lines.join('\n');
}
