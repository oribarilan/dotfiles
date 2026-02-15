import Gio from 'gi://Gio';
import Shell from 'gi://Shell';
import Meta from 'gi://Meta';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

const DBUS_IFACE = `
<node>
  <interface name="com.dotfiles.FocusOrLaunch">
    <method name="FocusOrLaunch">
      <arg type="s" direction="in" name="desktop_id"/>
    </method>
  </interface>
</node>`;

export default class FocusOrLaunchExtension extends Extension {
  enable() {
    this._dbusImpl = Gio.DBusExportedObject.wrapJSObject(DBUS_IFACE, this);
    this._dbusImpl.export(Gio.DBus.session, '/com/dotfiles/FocusOrLaunch');
  }

  disable() {
    this._dbusImpl?.unexport();
    this._dbusImpl = null;
  }

  FocusOrLaunch(desktopId) {
    const appSys = Shell.AppSystem.get_default();

    // Ensure .desktop suffix
    if (!desktopId.endsWith('.desktop'))
      desktopId += '.desktop';

    const app = appSys.lookup_app(desktopId);
    if (!app) {
      log(`[focus-or-launch] App not found: ${desktopId}`);
      return;
    }

    if (app.get_n_windows() > 0) {
      // App is running — get the most recent window and focus it directly
      const wins = app.get_windows();
      const win = wins[0];
      const workspace = win.get_workspace();
      const time = global.get_current_time();

      // Switch to the window's workspace if needed
      if (workspace)
        workspace.activate_with_focus(win, time);
      else
        win.activate(time);
    } else {
      // App is not running — launch it
      app.open_new_window(-1);
    }
  }
}
