indexing

	description: "[
	
		Provide mapping of error constants from EDOC_ERROR_CODES to string messages.
		
		Placeholders are marked with '{#}' where '#' is the number of replacement. 
		Zero is always the error code. 1, 2, etc. are indexes in the error data tuple.

	]"
	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_ERROR_MESSAGES

inherit

	ANY

	EDOC_ERROR_CODES
		export {NONE} all end

feature {NONE} -- Initialisation

	make_default_messages is
			-- Initialise default error messages.
		do
			Error_messages.put ("Options directory not found. Set the EIFFELDOC environment variable", Error_no_options_directory_found)

			Error_messages.put ("Option file '{1}' doesn't exist", Error_options_file_doesnt_exist)
			Error_messages.put ("Failed to open option file '{1}'", Error_options_file_open_read_failed)
			Error_messages.put ("Option '{1}' unknown in option file '{2}'", Error_unknown_option)
			Error_messages.put ("Invalid line '{1}' in option file '{2}'", Error_invalid_option_line)

			Error_messages.put ("Invalid boolean option '{1}' in option line '{2}'", Error_invalid_boolean_option)
			Error_messages.put ("Invalid env option '{1}' in option line '{2}'", Error_invalid_env_option)

			Error_messages.put ("File '{1}' not found", Error_file_not_found)
			Error_messages.put ("File '{1}' not readable", Error_file_not_readable)
			Error_messages.put ("File '{1}' not writable", Error_file_not_writeable)

			Error_messages.put ("Feature order file '{1}' not found", Error_feature_order_file_not_found)
			Error_messages.put ("CSS file '{1}' not found", Error_css_file_not_found)

			Error_messages.put ("Xace file '{1}' not found", Error_xace_file_not_found)
			Error_messages.put ("XAce file '{1}' not readable", Error_xace_file_not_readable)
			Error_messages.put ("Ace file '{1}' not found", Error_ace_file_not_found)
			Error_messages.put ("Ace file '{1}' not readable", Error_ace_file_not_readable)
			Error_messages.put ("ECF file '{1}' not found", error_ecf_file_not_found)

			Error_messages.put ("No input file specified: Ace, XAce system or XAce library", Error_no_input_file)
			Error_messages.put ("XAce file '{1}' of mounted library not found", Error_mounted_xace_not_found)
			Error_messages.put ("Failed to create output directory '{1}'", Error_create_output_directory)

			Error_messages.put ("Failed to parse ace file '{1}'", Error_parsing_ace)
			Error_messages.put ("Failed to parse xace file '{1}'", Error_parsing_xace)
			Error_messages.put ("Failed to parse ecf file '{1}'", error_parsing_ecf)

			Error_messages.put ("Failed to create directory '{1}'", Error_create_directory)

		end

feature -- Access

	Error_messages: DS_HASH_TABLE [STRING, INTEGER] is
			-- Table which maps error codes to error messages.
		once
			create Result.make (100)
			make_default_messages
		ensure
			result_exists: Result /= Void
		end

	Default_error_message: STRING is
			-- Message of errors whitout specialized message
		once
			Result := "Errorcode '{0}' - See utility.EDOC_ERROR_CODES for more information"
		ensure
			result_exists: Result /= Void
		end

end
