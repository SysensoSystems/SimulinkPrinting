printModelDoc - Helps to print the Simulink model in .html/.pdf/.word formats.
It takes the snapshots of each level of the model along with
the plots of the output or logged signal(optional) in hierarchical order.

Usage: Add utils folder into the MATLAB before calling printModelDoc command.

This utility has following advantages over the standard printing feature available
within MATLAB. https://mathworks.com/help/simulink/ug/printing-capabilities.html

1. Model subsystem level hierarchy will be available in the print.
2. Model simulation results can also be print along with the model.
3. More customization is possible as you have this source code.

Syntax:
>> printModelDoc(<'systemName'>,<'format'>)
>> printModelDoc(<'systemName'>,<'format'>,<variable>)
>> outputPath = printModelDoc(<'systemName'>,<'format'>)

<systemName> - can be a model or the subsystem path.
<format> - supported file formats pdf, html, word.
<variable> - Model simulation results. This is an optional parameter.
Supported Variable formats.
1. Simulink Dataset.
2. Model Datalogs.
3. Structure.
4. Structure with time.
outputPath - Output will be a folder containing the report of the model
in the given format. Folder name will be the system name suffixed by "_ModelViewer".

Example:
1. To print the Model images in word format.
printModelDoc('sldemo_autotrans','word')

2. To print the subsystem images in HTML format.
printModelDoc('sldemo_autotrans/Transmission','html')

3. To print the Model images in PDF format.
printModelDoc('sldemo_autotrans','pdf')

4. To print the Model images along with the signal plots in word format.
printModelDoc('sldemo_autotrans','word',sldemo_autotrans_output)

5. To print the Model images along with the signal plots in PDF format.
printModelDoc('sldemo_autotrans','pdf',sldemo_autotrans_output)

6. To print the Model images along with the signal plots HTML in word format.
printModelDoc('sldemo_autotrans','html',sldemo_autotrans_output)

7. To print the Model images along with the signal plots in all the three
formats.
printModelDoc('sim_autotrans',{'html','word','pdf'},sldemo_autotrans_output)

Developed by: Sysenso Systems, https://sysenso.com/
Contact: contactus@sysenso.com

Version:
1.0 - Initial Version.
1.1 - Fixed the naming issue with folder name utils/html_images.
