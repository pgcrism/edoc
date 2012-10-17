indexing

	description:

		"Options file for HTML output"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_OPTIONS_FILE

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

			-- HTML options
			option_processors.put (agent process_string (?, agent Options.set_title (?)), "title")
			option_processors.put (agent process_string (?, agent Options.set_short_title (?)), "short_title")
			option_processors.put (agent process_string (?, agent Options.set_version (?)), "version")
			option_processors.put (agent process_css (?), "css")
			option_processors.put (agent process_boolean (?, agent Options.set_edoc_notice_printed (?)), "print_edoc_notice")
			option_processors.put (agent process_string (?, agent Options.set_home_url (?)), "home_url")
		end

	process_css (a_value: STRING) is
			-- Process 'css' option.
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
				Options.set_original_css_file (a_filename)
			else
				Error_handler.raise_warning (Error_handler.Error_css_file_not_found, << a_value >>)
			end
		end
	
end
