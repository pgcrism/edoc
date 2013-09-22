note
	description: "[
	
		Objects that visit ET_FEATURE objects and extract the initial feature comment for documentation.
		Process the <precursor> comment.
	]"

	copyright: "Copyright (c) 20012, Paul-G. Crismer"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	EDOC_FEATURE_COMMENT_PROCESSOR

inherit
	ET_AST_NULL_PROCESSOR
--		redefine
--			process_attribute,
--			process_do_function,
--			process_do_procedure,
--			process_once_function,
--			process_once_procedure,
--			process_external_function,
--			process_external_procedure,
--			process_formal_argument_list
--		end

feature -- Access

	last_comment: STRING

feature -- Basic operations

	process_feature (a_feature: ET_FEATURE)
			-- Process `a_feature' extrating the comment immediately following the signature.
		do
			reset

			if a_feature.header_break /= Void then
				last_comment := a_feature.header_break.text
			else
				create last_comment.make_empty
			end
--			STRING_.left_adjust (last_comment)
--			STRING_.right_adjust (last_comment)
			if last_comment.as_lower.has_substring ("<precursor>") then
				process_precursor_comment (a_feature)
			end
		end

feature -- Inapplicable

	process_precursor_comment (a_feature: ET_FEATURE)
		do

		end

feature {NONE} -- Implementation

	reset
		do
			create last_comment.make_empty
		end

end
