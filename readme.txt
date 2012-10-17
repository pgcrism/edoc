EDoc: Eiffel API Documentation Generator
----------------------------------------

Author: Julian Tschannen
Contact: juliant@student.ethz.ch


This tool creates an API description of an Eiffel system or library.

Please send comments or suggestions.


Requirements
------------

Eiffel:
	Tested Eiffel compilers are ISE and SmartEiffel
	ISE: 5.6
	SmartEiffel: 2.2 Beta

	SmartEiffel's final release should work as soon as GOBO's CVS version works with it

GOBO:
	CVS Version of September 2005 or later
	The CVS Version is needed because GOBO's Eiffel parser had an API change this summer (2005)

Platform:
	Developed and tested on Linux Gentoo

	Since the only dependency is GOBO and all file handling is done through GOBO's file system
	classes the program should be fully compatible to all platforms which GOBO supports

Note:
	Since the developement used GOBO's CVS version and SmartEiffel's beta version, it's possible
	that minor changes have to be made as soon as the final versions of GOBO and SmartEiffel are
	available.


Installation
------------

- Change to EDoc directory
- Type 'geant compile'


Test EDoc
---------

- Change to EDoc directory
- Type 'edoc system.xace'

This will generate an API documentation of EDoc in the directory 'output'


Create GOBO API
---------------

- Change to EDoc directory
- Type 'edoc gobo'
- Generated documentation is in '$GOBO/doc/src'

Since GOBO is quite large, this can take some time


Create EiffelMedia API
----------------------
You need to have EiffelMedia installed. Note that the installed version might
alredy have a generated API documentation provided which will be overwritten

- Change to EDoc directory
- Type 'edoc em'
- Generated documentation is in '$EM/doc/src'


Create ePOSIX API
-----------------
You need to have ePOSIX installed.

- Change to EDoc directory
- Type 'edoc eposix'
- Generated documentation is in '$EPOSIX/doc/src'

If you want to create the documentation for a specific platform 
type 'edoc eposix.windows' or 'edoc eposix.unix'


Create ISE Libraries API
------------------------
You need to have Eiffel Studio installed.

- Change to EDoc directory
- Type 'edoc ise'
- Generated documentation is in '$ISE_EIFFEL/docs/src'


Create API of your own system
-----------------------------

- Change to EDoc directory
- Type one of
	- 'edoc path_to_your_ace.ace'
	- 'edoc path_to_your_xace.xace'
	- 'edoc path_to_your_options_file'
- Generated documentation is in 'output'

Note: If your xace is a library, it has to be named 'library.xace' otherwise it is assumed to be a system
Note: Generated documentation of an 'ace' file is not very pretty since the cluster structure is lost


General Notes
-------------

If you don't want any output shown, set the option '-s' (silent)

Error messages during parsing are from the GOBO Eiffel parser. If you think some documentation
is not complete, look if the parser had problems with the appropiate classes. Otherwise you can
ignore these errors if your library or system compiles with ISE or SmartEiffel.
