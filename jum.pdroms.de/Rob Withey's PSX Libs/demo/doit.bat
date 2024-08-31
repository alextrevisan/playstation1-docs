REM Make libps.a
cd ..
nmake clean
nmake

REM Make play.psx
cd demo
nmake clean
nmake
psexe play.psx
