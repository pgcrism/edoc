indexing

	description:

		"Error codes"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_ERROR_CODES

feature -- Access

	Error_no_options_directory_found: INTEGER is 100
			-- No options directory found

	Error_options_file_doesnt_exist: INTEGER is 103
			-- Options file doesn't exist

	Error_options_file_open_read_failed: INTEGER is 105
			-- Failed to open options file

	Error_unknown_option: INTEGER is 107
			-- Unkown option in option file

	Error_invalid_option_line: INTEGER is 108
			-- Invalid line in option file

	Error_invalid_boolean_option: INTEGER is 120
			-- Invalid boolean option

	Error_invalid_env_option: INTEGER is 121
			-- Invalid env option

	Error_file_not_found: INTEGER is 150
			-- File not found

	Error_file_not_readable: INTEGER is 151
			-- File not readable

	Error_file_not_writeable: INTEGER is 152
			-- File not writable

	Error_feature_order_file_not_found: INTEGER is 169
			-- Feature order file not found

	Error_css_file_not_found: INTEGER is 170
			-- CSS file not found

	Error_xml_header_file_not_found: INTEGER is 171
			-- xml_header_file file not found

	Error_xml_footer_file_not_found: INTEGER is 172
			-- xml_footer_file file not found

	Error_xace_file_not_found: INTEGER is 200
			-- Xace file not found

	Error_xace_file_not_readable: INTEGER is 201
			-- Xace file not found

	Error_ace_file_not_found: INTEGER is 202
			-- Ace file not found

	Error_ace_file_not_readable: INTEGER is 203
			-- Ace file not readable

	Error_no_input_file: INTEGER is 204
			-- No input file specified

	Error_mounted_xace_not_found: INTEGER is 206
			-- Mounted xace file not found

	Error_create_output_directory: INTEGER is 210
			-- Failed to create output directory

	Error_parsing_ace: INTEGER is 230
			-- Failed to parse ace file

	Error_parsing_xace: INTEGER is 231
			-- Failed to parse xace file

	Error_create_directory: INTEGER is 250
			-- Failed to create directory

end
