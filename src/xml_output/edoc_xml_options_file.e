indexing

	description:

		"Options file for XML output"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_OPTIONS_FILE

inherit

	EDOC_OPTIONS_FILE
		redefine
			make_from_filename
		end

create

	make_from_filename

feature {NONE} -- Initialisation

	make_from_filename (a_filename: STRING) is
			-- Initialise options from `a_filename'.
		do
			Precursor {EDOC_OPTIONS_FILE} (a_filename)

			-- XML options
			option_processors.put (agent process_string (?, agent Options.set_title (?)), "title")
			option_processors.put (agent process_string (?, agent Options.set_short_title (?)), "short_title")
			option_processors.put (agent process_string (?, agent Options.set_version (?)), "version")
			option_processors.put (agent process_xsd (?), "xsd")
			option_processors.put (agent process_xml_header_file(?), "xml_header_file")
			option_processors.put (agent process_xml_footer_file(?), "xml_footer_file")
			option_processors.put (agent process_boolean (?, agent Options.set_edoc_notice_printed (?)), "print_edoc_notice")
			option_processors.put (agent process_string (?, agent Options.set_home_url (?)), "home_url")
		end

	process_xsd (a_value: STRING) is
			-- Process 'xsd' option.
		require
			a_value_not_void: a_value /= Void
		local
			a_filename: STRING
		do
			a_filename := file_system.absolute_pathname (Execution_environment.interpreted_string (a_value))
			if not file_system.file_exists (a_filename) then
				a_filename := file_system.pathname (dirname, Execution_environment.interpreted_string (a_value))
			end
			if file_system.file_exists (a_filename) then
				Options.set_original_xsd_file (a_filename)
			else
				Error_handler.raise_warning (Error_handler.Error_css_file_not_found, << a_value >>)
			end
		end

	process_xml_header_file (a_value: STRING) is
			-- Process 'xml_header_file' option.
		require
			a_value_not_void: a_value /= Void
		local
			a_filename: STRING
		do
			a_filename := file_system.absolute_pathname (Execution_environment.interpreted_string (a_value))
			if not file_system.file_exists (a_filename) then
				a_filename := file_system.pathname (dirname, Execution_environment.interpreted_string (a_value))
			end
			if file_system.file_exists (a_filename) then
				options.set_xml_header_file (a_filename)
			else
				Error_handler.raise_warning (Error_handler.error_xml_header_file_not_found, << a_value >>)
			end
		end

	process_xml_footer_file (a_value: STRING) is
			-- Process 'xml_footer_file' option.
		require
			a_value_not_void: a_value /= Void
		local
			a_filename: STRING
		do
			a_filename := file_system.absolute_pathname (Execution_environment.interpreted_string (a_value))
			if not file_system.file_exists (a_filename) then
				a_filename := file_system.pathname (dirname, Execution_environment.interpreted_string (a_value))
			end
			if file_system.file_exists (a_filename) then
				options.set_xml_footer_file (a_filename)
			else
				Error_handler.raise_warning (Error_handler.error_xml_footer_file_not_found, << a_value >>)
			end
		end

end
