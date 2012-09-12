@echo off
if "%1" == "" goto :error
for %%X in (%1\*) do ..\..\utils\bin2hex\bin2hex %%X > %%X.hex
goto :end

:error
echo "usage: all2hex <subdir>"

:end

