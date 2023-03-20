package base.system;

#if windows
/**
 * Cool window utility from awesome peoples
 * @author DuskieWhy, TaeYai, BreezyMelee, YoshiCrafter, KadeDev
 */
@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
class WindowAPI
{
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 0, LWA_COLORKEY);
        }
    ')
	static public function getWindowsTransparent(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(1, 1, 1), 1, LWA_COLORKEY);
        }
    ')
	static public function getWindowsBackward(res:Int = 0)
	{
		return res;
	}

	@:functionCode('
    int darkMode = mode;
    HWND window = GetActiveWindow();
    if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
        DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
    }
    UpdateWindow(window);
    ')
	public static function setWindowColorMode(mode:Int):Void {} // 1 for dark 0 for light

}
#end