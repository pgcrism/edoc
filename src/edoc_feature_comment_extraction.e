note
	description: "[
	
		Objects that visit ET_FEATURE objects and extract the initial feature comment for documentation.
		Take account of
		* old syntax trees (with 'is' keyword)
		* new syntax trees (without 'is' keyword)
	]"
		
	copyright: "Copyright (c) 20012, Paul-G. Crismer"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class
	EDOC_FEATURE_COMMENT_EXTRACTION

inherit
	ET_AST_NULL_PROCESSOR
		redefine
			process_attribute,
			process_do_function,
			process_do_procedure,
			process_once_function,
			process_once_procedure,
			process_external_function,
			process_external_procedure,
			process_formal_argument_list
		end

feature -- Access

	last_comment: STRING

feature -- Basic operations

	process_feature (a_feature: ET_FEATURE)
			-- Process `a_feature' extrating the comment immediately following the signature.
		do
			reset
			a_feature.process (Current)
		end

feature -- Inapplicable

	process_attribute (an_attribute : ET_ATTRIBUTE)
		do
			--declared_type
			--assigner
			--semicolon
			if an_attribute.semicolon /= Void then
				process_semicolon (an_attribute.semicolon)
			elseif an_attribute.assigner /= Void then
				process_assigner (an_attribute.assigner)
			elseif an_attribute.declared_type /= Void then
				process_declared_type (an_attribute.declared_type)
			end
		end

	process_do_function (a_function : ET_DO_FUNCTION)
		do
			process_function (a_function)
		end

	process_do_procedure (a_procedure : ET_DO_PROCEDURE)
		do
			process_procedure (a_procedure)
		end

	process_once_function (a_function: ET_ONCE_FUNCTION)
		do
			process_function (a_function)
		end

	process_once_procedure (a_procedure: ET_ONCE_PROCEDURE)
		do
			process_procedure (a_procedure)
		end

	process_external_function (a_function: ET_EXTERNAL_FUNCTION)
		do
			process_function (a_function)
		end

	process_external_procedure (a_procedure: ET_EXTERNAL_PROCEDURE)
		do
			process_procedure (a_procedure)
		end

	process_function (a_function: ET_FUNCTION)
		do
			--declared_type
			--assigner
			--is_keyword
			if a_function.is_keyword /= Void then
				process_is_keyword (a_function.is_keyword)
			elseif a_function.assigner /= Void then
				process_assigner (a_function.assigner)
			elseif a_function.declared_type /= Void then
				process_declared_type (a_function.declared_type)
			end
		end

	process_assigner (an_assigner: ET_ASSIGNER)
		do
			process_break (an_assigner.break)
		end

	process_semicolon (a_semicolon: ET_SEMICOLON_SYMBOL)
		do
			process_break (a_semicolon.break)
		end

	process_declared_type (a_declared_type: ET_DECLARED_TYPE)
		do
			process_break (a_declared_type.break)
		end

	process_procedure (a_procedure : ET_PROCEDURE)
		do
			--*last synonym.extended_name
			--arguments
			--is_keyword

			if a_procedure.is_keyword /= Void then
				process_is_keyword (a_procedure.is_keyword)
			elseif a_procedure.arguments /= Void then
				process_formal_argument_list (a_procedure.arguments)
			elseif a_procedure.synonym /= Void then
				process_synonym (a_procedure.synonym)
			else
				process_simple_procedure (a_procedure)
			end

		end

	process_is_keyword (a_keyword: ET_KEYWORD)
		do
			process_break (a_keyword.break)
		end

	process_formal_argument_list (an_argument_list: ET_FORMAL_ARGUMENT_LIST)
		do
			process_break (an_argument_list.break)
		end

	process_synonym (a_feature: ET_FEATURE)
		do
			process_feature (a_feature)
		end

	process_simple_procedure (a_procedure: ET_PROCEDURE)
			-- Process argument-less procedure without any synonym
		do
			process_break (a_procedure.break)
		end

	process_break (a_break: ET_BREAK)
		do
			create last_comment.make_from_string (a_break.text)
		end

feature {NONE} -- Implementation

	reset
		do
			create last_comment.make_empty
		end

end
