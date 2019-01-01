@echo off
echo Creating ROM image file. 
echo Please do not forget to reset persistent model data!
del MPFSImg.bin
mpfs .\WebPages MPFSImg.bin
del romimage.bin
copy /b header.bin +MPFSImg.bin romimage.bin