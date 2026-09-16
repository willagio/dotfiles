ObjC.import('CoreGraphics');

function run(argv) {
    if (argv.length !== 1 || !['prev', 'next', 'list'].includes(argv[0])) {
        throw new Error('Usage: cycle-stack.js prev|next|list');
    }

    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    function aerospace(args) {
        return app.doShellScript(
            'export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; aerospace ' + args
        ).trim();
    }

    const workspaceWindows = JSON.parse(aerospace(
        "list-windows --workspace focused --json --format '%{window-id} %{app-name} %{window-title} %{window-parent-container-layout}'"
    ));
    if (workspaceWindows.length === 0) {
        return argv[0] === 'list' ? JSON.stringify({focusedId: null, windows: []}) : undefined;
    }
    // Focus can move to an empty workspace between the two queries.
    const focusedId = Number(aerospace("list-windows --focused --format '%{window-id}' 2>/dev/null || true"));
    const focused = workspaceWindows.find(window => window['window-id'] === focusedId);
    if (!focused) {
        return argv[0] === 'list' ? JSON.stringify({focusedId: null, windows: []}) : undefined;
    }
    if (!['h_accordion', 'v_accordion'].includes(focused['window-parent-container-layout'])) {
        return argv[0] === 'list' ? JSON.stringify({focusedId, windows: [focused]}) : undefined;
    }
    const candidates = workspaceWindows
        .filter(window => ['h_accordion', 'v_accordion'].includes(window['window-parent-container-layout']))
        .map(window => window['window-id']);

    const windows = ObjC.deepUnwrap(ObjC.castRefToObject(
        $.CGWindowListCopyWindowInfo($.kCGWindowListOptionAll, $.kCGNullWindowID)
    ));
    const current = windows.find(window => window.kCGWindowNumber === focusedId);
    if (!current) {
        return argv[0] === 'list' ? JSON.stringify({focusedId, windows: [focused]}) : undefined;
    }

    // Zero accordion padding gives stack members the same origin. Sizes may
    // differ because applications can enforce their own minimum window size.
    const origin = current.kCGWindowBounds;
    const stack = windows.filter(window => {
        const bounds = window.kCGWindowBounds;
        return candidates.includes(window.kCGWindowNumber)
            && Math.abs(bounds.X - origin.X) < 1
            && Math.abs(bounds.Y - origin.Y) < 1;
    }).map(window => window.kCGWindowNumber).sort((a, b) => a - b);
    if (argv[0] === 'list') {
        return JSON.stringify({
            focusedId,
            windows: stack.map(id => workspaceWindows.find(window => window['window-id'] === id))
        });
    }
    if (stack.length < 2) return;

    const offset = argv[0] === 'next' ? 1 : -1;
    const target = stack[(stack.indexOf(focusedId) + offset + stack.length) % stack.length];
    if (Number(aerospace("list-windows --focused --format '%{window-id}'")) !== focusedId) return;
    aerospace('focus --window-id ' + target);
}
