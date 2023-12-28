# multiexecute_commandverb
windows shell handler for multiple files
example helper for mass conversion of images to .jpg calling imagemagick convert.exe
line 171             LPCWSTR cmd = (LPCWSTR)L"C:\\Script\\AHK\\z_ConTxt\\manyargumentswithbill.ahk";
defines the location of the helper
"ffa07888-75bd-471a-b325-59274e73227f" is the uuid /clsid of the handler and should be added to the relevant registrykey eg:
Computer\HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\Process_IMAGE\Shell\pic2jpg2\command
DelegateExecute {FFA07888-75BD-471A-B325-59274E73227F} 
