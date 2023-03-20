This is the crash handler, you can modify the name, assets and quotes, but also modify the crash handler itself.
Thanks to gedehari for this customizable crash handler, i cant thank him enough oh my gosh

<!-- Compilation instructions --!>
To compile it, you first have to run the crash handler setup on the compile-and-setup-files folder.
After that, run the build crash handler bat file on the compile-and-setup-files folder.
After the crash handler being compiled, put the exe from the export folder of the crash dialog and directly put it
in the engine directory (which means in your engine folder, where Project.xml is located) then you should be good to go

<!-- The Crash handler is only available on release builds. To make it available to other builds too, go to Project.xml
on the line 51 where "FEP-CrashDialog" should be shown in the line somewhere, and remove `if="release"` --!>