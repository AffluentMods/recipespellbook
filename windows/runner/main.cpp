#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "app_links/app_links_plugin_c_api.h"
#include "flutter_window.h"
#include "utils.h"

// recipespellbook:// links on Windows:
//  * windows\installer.iss registers the scheme for the Inno install
//    ([Registry]), and msix_config in pubspec.yaml (protocol_activation) for
//    the Store package. Both start this exe with the link as its argument.
//  * Here: only one copy runs at a time. A second launch hands its link (if
//    any) to the open window, brings that window to the front and exits, so
//    two copies never work on the same database.
//  * app_links passes the link (from the command line, or handed over) to
//    lib\main.dart (_initDeepLinks), which opens it via
//    lib\utils\invite_link_parser.dart.

namespace {

// The window title, also how a second launch finds the open window.
constexpr const wchar_t kWindowTitle[] = L"Recipe Spellbook";

// Held by the running copy from before its window exists until it exits.
constexpr const wchar_t kSingleInstanceMutex[] =
    L"Local\\AffluentLabs.RecipeSpellbook.SingleInstance";

// From the app_links Windows setup: when a copy is already open, sends it this
// launch's link and brings its window to the front. Returns false when no copy
// has a window open.
bool SendAppLinkToInstance(const std::wstring& title) {
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", title.c_str());
  if (!hwnd) {
    return false;
  }

  // Does nothing when this launch has no link.
  SendAppLink(hwnd);

  WINDOWPLACEMENT place = {sizeof(WINDOWPLACEMENT)};
  ::GetWindowPlacement(hwnd, &place);
  switch (place.showCmd) {
    case SW_SHOWMAXIMIZED:
      ::ShowWindow(hwnd, SW_SHOWMAXIMIZED);
      break;
    case SW_SHOWMINIMIZED:
      ::ShowWindow(hwnd, SW_RESTORE);
      break;
    default:
      ::ShowWindow(hwnd, SW_NORMAL);
      break;
  }
  ::SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0,
                 SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
  ::SetForegroundWindow(hwnd);
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // A copy is already open: it takes this launch's link, if any.
  if (SendAppLinkToInstance(kWindowTitle)) {
    return EXIT_SUCCESS;
  }
  // No window yet, but a copy may be just starting or still closing. Give it
  // up to five seconds to open its window (hand over to it) or to exit (then
  // this copy starts).
  HANDLE single_instance = ::CreateMutex(nullptr, TRUE, kSingleInstanceMutex);
  if (single_instance && ::GetLastError() == ERROR_ALREADY_EXISTS) {
    for (int i = 0; i < 50; ++i) {
      if (::WaitForSingleObject(single_instance, 100) != WAIT_TIMEOUT) {
        break;
      }
      if (SendAppLinkToInstance(kWindowTitle)) {
        return EXIT_SUCCESS;
      }
    }
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 800);
  if (!window.Create(kWindowTitle, origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
