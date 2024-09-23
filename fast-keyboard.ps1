Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.ComponentModel;

public static class FilterKeys {  

    [StructLayout(LayoutKind.Sequential)]
    private struct FILTERKEYS {
        public uint cbSize;
        public System.UInt32 dwFlags;
        public System.UInt32 iWaitMSec;
        public System.UInt32 iDelayMSec;
        public System.UInt32 iRepeatMSec;
        public System.UInt32 iBounceMSec;
    }

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref FILTERKEYS pvParam, int fWinIni);

    const int SPI_GETFILTERKEYS = 0x0032;
    const int SPI_SETFILTERKEYS = 0x0033;

    private static void check( bool ok ) {
        if( ! ok )
            throw new Win32Exception( Marshal.GetLastWin32Error() );
    }

    public static void DisplayCurrentValues() {
        Console.WriteLine("Reading current applied settings");
        FILTERKEYS filter_keys = new FILTERKEYS();
        filter_keys.cbSize = (uint)Marshal.SizeOf(filter_keys);
	    check(SystemParametersInfo(SPI_GETFILTERKEYS, 0, ref filter_keys, 0));
        Console.WriteLine("Flags: " + filter_keys.dwFlags);
        Console.WriteLine("DelayBeforeAcceptance: " + filter_keys.iWaitMSec);
        Console.WriteLine("AutoRepeatDelay: " + filter_keys.iDelayMSec);
        Console.WriteLine("AutoRepeatRate: " + filter_keys.iRepeatMSec);
        Console.WriteLine("BounceTime: " + filter_keys.iBounceMSec);
    }   

    public static void ApplyValues(uint flags, uint delay, uint rate) {
        Console.WriteLine("Applying values: flags {0:G}, repeat delay {1:G}ms, repeat rate {2:G}ms", flags, delay, rate);

        FILTERKEYS filter_keys = new FILTERKEYS();
        filter_keys.cbSize = (uint)Marshal.SizeOf(filter_keys);
        filter_keys.dwFlags = flags;
        filter_keys.iWaitMSec = 0;
        filter_keys.iDelayMSec = delay;
        filter_keys.iRepeatMSec = rate;
        filter_keys.iBounceMSec = 0;

        check(SystemParametersInfo(SPI_SETFILTERKEYS, 0, ref filter_keys, 0));
        Console.WriteLine("Applied");
    }
}
'@

[FilterKeys]::DisplayCurrentValues()
[FilterKeys]::ApplyValues(59, 350, 10)
