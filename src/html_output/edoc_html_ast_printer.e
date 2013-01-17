indexing

	description:

		"AST printer for HTML output"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_AST_PRINTER

inherit

	ET_AST_PRINTER
		rename
			make as make_ast_printer,
			file as ast_file,
			set_file as set_ast_file
		redefine
			process_break,
			process_class,
			process_class_type,
			process_convert_feature_list,
			process_current,
			process_false_constant,
			process_identifier,
			process_indexing_list,
			process_invariants,
			process_keyword,
			process_parent_list,
			process_postconditions,
			process_preconditions,
			process_regular_manifest_string,
			process_special_manifest_string,
			process_result,
			process_symbol,
			process_tagged_assertion,
			process_true_constant,
			process_verbatim_string,
			process_void
		end

	EDOC_SHARED_ACCESS
		export {NONE} all end

	EDOC_SHARED_HTML_CONTEXT
		export {NONE} all end

	EDOC_SHARED_CSS_CONSTANTS
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

create

	make

feature {NONE} -- Initialisation

	make (a_universe: like universe) is
			-- Initialise with 'a_file'.
		do
			universe := a_universe
			make_null
		end

feature -- Access


	universe: ET_UNIVERSE
			-- Surrounding universe

	file: EDOC_HTML_OUTPUT_FILE
			-- Output file

feature -- Status report


	are_strings_comments: BOOLEAN
			-- Are strings which are currently encountered comments?

feature -- Element change

	set_file (a_file: like file) is
			-- Set 'file' to 'a_file'.
		require
			a_file_not_void: a_file /= Void
		do
			file := a_file
			ast_file := a_file
		ensure
			file_set: file = a_file
		end

feature -- Processing

	process_break (a_break: ET_BREAK) is
			-- Process `a_break'.
		do
			-- Only process single space breaks
			if a_break /= Void and then a_break.text.count > 0 then
				file.put_character (' ')
			end
		end

	process_class (a_class: ET_CLASS) is
			-- Process 'a_class'.
		local
			a_line: STRING
		do
			et_class := a_class

			-- TODO: move feature clause, feature and creator indexing to EDOC_CONTEXT so multiple output formats can use these lists
			build_feature_clauses_list
			build_features_list
			build_creators

			if Options.is_feature_list_generated then
				print_feature_list
			end

			-- Indexing
			if a_class.first_indexing /= Void and then a_class.first_indexing.count > 0 then
				are_strings_comments := True
				process_indexing_list (a_class.first_indexing)
				are_strings_comments := False
			end
			-- Class keywords
			file.start_tag ("h2")
			create a_line.make_empty
			if a_class.frozen_keyword /= Void then
				a_line.append_string ("frozen")
				a_line.append_character (' ')
			end
			if a_class.class_mark /= Void then
				a_line.append_string (a_class.class_mark.text)
				a_line.append_character (' ')
			end
			if a_class.external_keyword /= Void then
				a_line.append_string ("external")
				a_line.append_character (' ')
			end
			a_line.append_string ("class")
			file.tag_css_content ("span", css_keyword, a_line)

			-- Class name
			file.tag_css_content ("span", css_class_name, a_class.name.name)
			if a_class.formal_parameters /= Void then
				file.indent
				file.put_string ("<span class=%"non-bold%">")
				a_class.formal_parameters.process (Current)
				file.put_string ("</span>%N")
			end
			file.end_tag

			-- Obsolete message
			if a_class.obsolete_message /= Void then
				are_strings_comments := True
				file.tag_css_content ("h2", css_keyword, "obsolete")
				file.start_tag_css ("div", css_indent)
				a_class.obsolete_message.manifest_string.process (Current)
				file.end_tag
				are_strings_comments := False
			end

			-- Inherit
			if a_class.parents /= Void and then a_class.parents.count > 0 then
				process_parent_list (a_class.parents)
			end

			-- Creators
			if not creators.is_empty then
				process_creators
			end

			-- Convert
			if a_class.convert_features /= Void then
				a_class.convert_features.process (Current)
			end

			-- Features
			if not features.is_empty then
				process_features_list
			end

			-- Invariants
			process_invariants (a_class.invariants)

			-- Indexing
			if a_class.second_indexing /= Void and then a_class.second_indexing.count > 0 then
				are_strings_comments := True
				process_indexing_list (a_class.second_indexing)
				are_strings_comments := False
			end
			file.tag_css_content ("span", css_keyword, "end")
		end

	process_class_type (a_type: ET_CLASS_TYPE) is
			-- Process `a_type'.
		local
			a_type_mark: ET_TYPE_MARK
			a_link: STRING
		do
			a_type_mark := a_type.type_mark
			if a_type_mark /= Void then
				a_type_mark.process (Current)
			end
			a_link := html_context.class_link_by_name (a_type.name)
			if a_link = Void then
				file.put_string (file.tag_css_content_to_string ("span", css_class_name, a_type.name.name))
			else
				file.put_string (file.link_css_content_to_string (a_link, css_linked_class_name, a_type.name.name))
			end
		end

	process_convert_feature_list (a_list: ET_CONVERT_FEATURE_LIST) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
		do
			file.tag_css_content ("h2", css_keyword, "convert")
			file.start_tag_css ("div", css_indent)
			nb := a_list.count
			from i := 1 until i > nb loop
				file.start_tag ("div")
				a_list.item (i).process (Current)
				file.end_tag
				i := i + 1
			end
			file.end_tag
		end

	process_creators is
			-- Process 'creators'.
		local
			a_clients: ET_CLIENT_LIST
		do
			from
				creators.start
			until
				creators.after
			loop
				if a_clients = Void or else a_clients /= creators.item_for_iteration.second then
					if a_clients /= Void then
						file.end_tag
						file.start_tag ("h2")
						file.tag_css_content ("span", css_keyword, "create")
					else
						file.start_tag ("h2")
						file.tag_attributes_content ("a", << "id", "create" >>, file.tag_css_content_to_string ("span", css_keyword, "create"))
					end
					a_clients := creators.item_for_iteration.second
					-- TODO: refactor ANY check (what about GENERAL?)
					if a_clients.count > 0 and not (a_clients.count = 1 and then a_clients.item (1).name.name.is_equal ("ANY")) then
						file.content_line (print_client_list_to_string (a_clients))
					end
					file.end_tag
					file.start_tag_css ("div", css_feature_clause_body)
				end
				-- Print 'feature'
				process_feature (creators.item_for_iteration.first, True)

				creators.forth
			end
			file.end_tag
		end

	process_current (an_expression: ET_CURRENT) is
			-- Process `an_expression'.
		do
			process_special_keyword (an_expression)
		end

	process_false_constant (a_constant: ET_FALSE_CONSTANT) is
			-- Process `a_constant'.
		do
			process_special_keyword (a_constant)
		end

	process_feature (a_feature: ET_FEATURE; is_creator: BOOLEAN) is
			-- Process 'a_feature'.
		local
			a_query: ET_QUERY
			a_routine: ET_ROUTINE
			precursors: DS_BILINKED_LIST [ET_FEATURE]
			a_precursor: ET_FEATURE
			cursor: DS_LIST_CURSOR [ET_FEATURE]
			a_feature_name, comment_text: STRING
			a_prefix_name: ET_PREFIX_NAME
			an_infix_name: ET_INFIX_NAME
		do
			a_query ?= a_feature
			a_routine ?= a_feature

			a_feature_name := html_context.xhtml_escaped_string (a_feature.name.name)

			from
				create precursors.make_default
				a_precursor := a_feature.first_precursor
			until
				a_precursor = Void
			loop
				precursors.put_first (a_precursor)
				a_precursor := a_precursor.first_precursor
			end

			file.start_tag_css ("div", css_feature)

			file.start_tag ("h3")
			file.indent
			if a_feature.frozen_keyword /= Void then
				a_feature.frozen_keyword.process (Current)
				file.put_character (' ')
			end
			an_infix_name ?= a_feature.name
			a_prefix_name ?= a_feature.name
			if an_infix_name /= Void then
				file.start_tag_attributes ("a", << "id", html_context.feature_anchor_by_feature (a_feature) >>)
				file.tag_css_content ("span", css_keyword, "infix")
				file.tag_css_content ("span", css_symbol, "%""+an_infix_name.operator_name.literal+"%"")
				file.end_tag
			elseif a_prefix_name /= Void then
				file.start_tag_attributes ("a", << "id", html_context.feature_anchor_by_feature (a_feature) >>)
				file.tag_css_content ("span", css_keyword, "prefix")
				file.tag_css_content ("span", css_symbol, "%""+a_prefix_name.operator_name.literal+"%"")
				file.end_tag
			else
				if is_creator then
					file.put_string (file.tag_attributes_content_to_string ("a", << "id", html_context.creator_anchor_by_feature (a_feature) >>, file.tag_css_content_to_string ("span", css_feature_name, a_feature_name)))
				else
					file.put_string (file.tag_attributes_content_to_string ("a", << "id", html_context.feature_anchor_by_feature (a_feature) >>, file.tag_css_content_to_string ("span", css_feature_name, a_feature_name)))
				end
			end
			if a_feature.arguments /= Void then
				file.put_character (' ')
				a_feature.arguments.process (Current)
			end
			if a_query /= Void then
				a_query.declared_type.process (Current)
			end
			file.put_new_line
			file.end_tag
			file.start_tag_css ("div", css_feature_body)

			-- Comment
			if a_feature.header_break /= Void then
				comment_text := a_feature.header_break.text
			else
				create comment_text.make_empty
			end
			STRING_.left_adjust (comment_text)
			STRING_.right_adjust (comment_text)
			-- TODO: take renaming into account and print 'From old_feature_name in class_name'
			if not precursors.is_empty then
				comment_text.append_string ("%N -- (From "+precursors.first.implementation_class.name.name+")%N")
			elseif a_feature.implementation_class /= et_class then
				comment_text.append_string ("%N -- (From "+a_feature.implementation_class.name.name+")%N")
			end

			if not comment_text.is_empty then
				file.start_tag_css ("div", css_feature_comment_body)
				print_comment (comment_text)
				file.end_tag
			end

			if a_feature.obsolete_message /= Void then
				are_strings_comments := True
				file.tag_css_content ("div", css_keyword, "obsolete")
				file.start_tag_css ("div", css_indent)
				a_feature.obsolete_message.manifest_string.process (Current)
				file.end_tag
				are_strings_comments := False
			end

			cursor := precursors.new_cursor
			from
				cursor.start
			until
				cursor.after
			loop
				if cursor.item.preconditions /= Void then
					cursor.item.preconditions.process (Current)
				end
				cursor.forth
			end
			if a_feature.preconditions /= Void then
				a_feature.preconditions.process (Current)
			end
			if a_feature.is_deferred then
				file.tag_css_content ("div", css_keyword, "deferred")
			end
			from
				cursor.start
			until
				cursor.after
			loop
				if cursor.item.postconditions /= Void then
					cursor.item.postconditions.process (Current)
				end
				cursor.forth
			end
			if a_feature.postconditions /= Void then
				a_feature.postconditions.process (Current)
			end
			file.end_tag
			file.end_tag
		end

	process_features_list is
			-- Process 'features'.
		local
			a_clause: DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]
			a_clients: ET_CLIENT_LIST
			last_clause: STRING
			last_clients: ET_CLIENT_LIST
			is_feature_clause_printed: BOOLEAN
		do
			from
				feature_clauses.start
			until
				feature_clauses.after
			loop
				a_clause := feature_clauses.item_for_iteration
				is_feature_clause_printed := False
				from
					features.start
				until
					features.after
				loop
					if features.item_for_iteration.feature_clause = a_clause.first then
						if not is_feature_clause_printed then
							is_feature_clause_printed := True

							-- Check if new feature clause keyword has to be printed
							if last_clause = Void or else (not last_clause.is_equal (a_clause.second.second) or (last_clients = Void or else not last_clients.same_clients (a_clause.first.clients))) then
								if last_clause /= Void then
									file.end_tag
								end

								file.start_tag ("h2")
								if last_clause = Void or else not last_clause.is_equal (a_clause.second.second) then
									file.tag_attributes_content ("a", << "id", "clause-"+html_context.xhtml_compatible_anchor (a_clause.second.second), "class", css_keyword >>, "feature")
								else
									file.tag_css_content ("span", css_keyword, "feature")
								end
								-- TODO: refactor ANY check (what about GENERAL?)
								a_clients := a_clause.first.clients
								if a_clients.count > 0 and not (a_clients.count = 1 and then a_clients.item (1).name.name.is_equal ("ANY")) then
									file.content_line (print_client_list_to_string (a_clause.first.clients))
								end
								file.tag_css_content ("span", css_comment, "-- "+a_clause.second.second)
								file.end_tag
								file.start_tag_css ("div", css_feature_clause_body)

			 					last_clause := a_clause.second.second
			 					last_clients := a_clause.first.clients
							end

						end
						process_feature (features.item_for_iteration, False)
					end
					features.forth
				end
				feature_clauses.forth
			end
			if last_clause /= Void then
				file.end_tag
			end
		end

	process_identifier (an_identifier: ET_IDENTIFIER) is
			-- Process `an_identifier'.
		local
			a_feature: ET_FEATURE
			a_link: STRING
		do
			a_feature := et_class.named_feature (an_identifier)
			if a_feature = Void or else not features.has (a_feature) then
				process_token (an_identifier)
			else
				a_link := html_context.feature_link_by_feature (a_feature, et_class)
				if a_link = Void then
					file.put_string (file.tag_css_content_to_string ("span", css_feature_name, an_identifier.name))
				else
					file.put_string (file.link_css_content_to_string (a_link, css_linked_feature_name, an_identifier.name))
				end
				process_break (an_identifier.break)
			end
		end

	process_indexing_list (a_list: ET_INDEXING_LIST) is
			-- Process 'a_list'.
		local
			i, nb: INTEGER
			an_item: ET_INDEXING
			a_tag: ET_TAG
		do
			file.tag_css_content ("h2", css_keyword, "note") -- "indexing")
			file.start_tag_css ("div", css_indexing_list)

			nb := a_list.count
			from i := 1 until i > nb loop
				an_item := a_list.item (i).indexing_clause
				a_tag := an_item.tag
				if a_tag /= Void and then not Options.ignored_indexing_tags.has (a_tag.identifier.name) then
					file.tag_css_content ("h3", css_indexing_tag, a_tag.identifier.name)
					file.start_tag_css ("div", css_indexing_body)
					an_item.terms.process (Current)
					file.end_tag
				end
				i := i + 1
			end

			file.end_tag
		end

	process_invariants (a_list: ET_INVARIANTS) is
			-- Process `a_list'.
		require else
			a_list_can_be_void: a_list = Void or a_list /= Void
		local
			i, nb, j, ancestor_count: INTEGER
			ancestor: ET_CLASS
			tagged_assertion: ET_TAGGED_ASSERTION
		do
			file.tag_attributes_content ("h2", << "class", css_keyword, "id", "invariant" >>, "invariant")
			file.start_tag_css ("div", css_assertion_body)
			if a_list /= Void then
				nb := a_list.count
				from i := 1 until i > nb loop
					tagged_assertion ?= a_list.item (i)
					if tagged_assertion = Void then
						file.indent
						a_list.item (i).process (Current)
						file.put_string ("<br/>%N")
					else
						a_list.item (i).process (Current)
					end
					i := i + 1
				end
			end
			ancestor_count := et_class.ancestors.count
			from j := 1 until j > ancestor_count loop
				ancestor := universe.class_by_name (et_class.ancestors.item (j).name.name)
				if ancestor /= Void and then ancestor.invariants /= Void then
					if j > 1 or a_list /= Void then
						file.tag ("br")
					end
					file.tag_css_content ("div", css_invariant_comment, "-- From "+file.print_class_name_to_string (ancestor))
					nb := ancestor.invariants.count
					from i := 1 until i > nb loop
						tagged_assertion ?= ancestor.invariants.item (i)
						if tagged_assertion = Void then
							file.indent
							ancestor.invariants.item (i).process (Current)
							file.put_string ("<br>%N")
						else
							ancestor.invariants.item (i).process (Current)
						end
						i := i + 1
					end
				end
				j := j + 1
			end
			file.end_tag
		end

	process_keyword (a_keyword: ET_KEYWORD) is
			-- Process `a_keyword'.
		do
			file.put_string (file.tag_css_content_to_string ("span", css_keyword, a_keyword.text))
			process_break (a_keyword.break)
		end

	process_special_keyword (a_keyword: ET_KEYWORD) is
			-- Process `a_keyword'.
		do
			file.put_string (file.tag_css_content_to_string ("span", css_special_keyword, a_keyword.text))
			process_break (a_keyword.break)
		end

	process_parent_list (a_list: ET_PARENT_LIST) is
			-- Process `a_list'.
		do
			if not available_parents (et_class).is_empty then
				file.tag_css_content ("h2", css_keyword, a_list.inherit_keyword.text)
				print_parent_list (et_class)
			end
		end

	process_postconditions (a_list: ET_POSTCONDITIONS) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
			tagged_assertion: ET_TAGGED_ASSERTION
		do
			nb := a_list.count
			if nb > 0 then
				if a_list.then_keyword = Void then
					file.tag_css_content ("h4", css_keyword, "ensure")
				else
					file.tag_css_content ("h4", css_keyword, "ensure then")
				end
				file.start_tag_css ("div", css_assertion_body)
				from i := 1 until i > nb loop
					tagged_assertion ?= a_list.item (i)
					if tagged_assertion = Void then
						file.indent
						a_list.item (i).process (Current)
						file.put_string ("<br/>%N")
					else
						a_list.item (i).process (Current)
					end
					i := i + 1
				end
				file.end_tag
			end
		end

	process_preconditions (a_list: ET_PRECONDITIONS) is
			-- Process `a_list'.
		local
			i, nb: INTEGER
			tagged_assertion: ET_TAGGED_ASSERTION
		do
			nb := a_list.count
			if nb > 0 then
				if a_list.else_keyword = Void then
					file.tag_css_content ("h4", css_keyword, "require")
				else
					file.tag_css_content ("h4", css_keyword, "require else")
				end
				file.start_tag_css ("div", css_assertion_body)
				nb := a_list.count
				from i := 1 until i > nb loop
					tagged_assertion ?= a_list.item (i)
					if tagged_assertion = Void then
						file.indent
						a_list.item (i).process (Current)
						file.put_string ("<br/>%N")
					else
						a_list.item (i).process (Current)
					end
					i := i + 1
				end
				file.end_tag
			end
		end

	process_regular_manifest_string (a_string: ET_REGULAR_MANIFEST_STRING) is
			-- Process `a_string'.
		do
			if are_strings_comments then
				print_comment (a_string.literal)
			else
				file.put_character ('%"')
				file.put_string (a_string.literal)
				file.put_character ('%"')
				process_break (a_string.break)
			end
		end

	process_result (an_expression: ET_RESULT) is
			-- Process `an_expression'.
		do
			process_special_keyword (an_expression)
		end

	process_special_manifest_string (a_string: ET_SPECIAL_MANIFEST_STRING) is
			-- Process `a_string'.
		local
			i: INTEGER
		do
			if are_strings_comments then
				from i := 1 until i = 0 loop
					i := a_string.literal.substring_index ("%%%N", i)
					if i > 0 then
						a_string.literal.remove (i)
						i := a_string.literal.index_of ('%%', i)
						a_string.literal.remove (i)
					end
				end
				print_comment (a_string.literal)
			else
				file.put_character ('%"')
				file.put_string (a_string.literal)
				file.put_character ('%"')
				process_break (a_string.break)
			end
		end

	process_symbol (a_symbol: ET_SYMBOL) is
			-- Process `a_symbol'.
		local
			text: STRING
		do
			text := STRING_.replaced_all_substrings (a_symbol.text, "<", "&lt;")
			text := STRING_.replaced_all_substrings (text, ">", "&gt;")
			file.put_string (file.tag_css_content_to_string ("span", css_symbol, text))
			if
				not a_symbol.is_right_brace and then
				not a_symbol.is_left_brace
			then
				process_break (a_symbol.break)
			end
		end

	process_tagged_assertion (an_assertion: ET_TAGGED_ASSERTION) is
			-- Process `an_assertion'.
		local
			an_expression: ET_EXPRESSION
		do
			file.indent
			file.put_string (file.tag_css_content_to_string ("span", css_assertion_tag, an_assertion.tag.identifier.name+":"))
			file.put_character (' ')
			an_expression := an_assertion.expression
			if an_expression /= Void then
				an_expression.process (Current)
			end
			file.put_string ("<br/>%N")
		end

	process_true_constant (a_constant: ET_TRUE_CONSTANT) is
			-- Process `a_constant'.
		do
			process_special_keyword (a_constant)
		end

	process_verbatim_string (a_string: ET_VERBATIM_STRING) is
			-- Process `a_string'.
		do
			if are_strings_comments then
				print_comment (a_string.literal)
			else
				file.put_character ('%"')
				file.put_string (a_string.marker)
				file.put_character ('[')
				file.put_string (a_string.open_white_characters)
				file.put_string (a_string.literal)
				file.put_string (a_string.close_white_characters)
				file.put_character (']')
				file.put_string (a_string.marker)
				file.put_character ('%"')
				process_break (a_string.break)
			end
		end

	process_void (an_expression: ET_VOID) is
			-- Process `an_expression'.
		do
			process_special_keyword (an_expression)
		end

feature {NONE} -- Implementation

	et_class: ET_CLASS
			-- Current class		

	creators: DS_LINKED_LIST [DS_PAIR [ET_FEATURE, ET_CLIENT_LIST]]
			-- Creators of class

	feature_clauses: DS_ARRAYED_LIST [DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]]
			-- Feature clauses of 'et_class'

	features: DS_ARRAYED_LIST [ET_FEATURE]
			-- Features of 'et_class'

	build_feature_clauses_list is
			-- Build feature clauses list for 'et_class'
		local
			i, nb, j, ancestor_count: INTEGER
			ancestor: ET_CLASS
			a_feature_clause: ET_FEATURE_CLAUSE
			a_name: STRING
			an_index: INTEGER
		do
			create feature_clauses.make (30)
			if et_class.feature_clauses /= Void then
				nb := et_class.feature_clauses.count
				from i := 1 until i > nb loop
					a_feature_clause := et_class.feature_clauses.item (i)
					a_name := feature_clause_name (a_feature_clause)
					if not Options.ignored_feature_clauses.has (a_name) then
						if not (Options.is_feature_clause_export_none_ignored and a_feature_clause.clients.has_class (universe.none_type.base_class)) then
							Options.feature_clause_order.start
							Options.feature_clause_order.search_forth (a_name)
							if Options.feature_clause_order.off then
								an_index := Options.user_defined_feature_clause_index
							else
								an_index := Options.feature_clause_order.index
							end
							feature_clauses.force_last (create {DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]}.make (a_feature_clause, create {DS_PAIR [INTEGER, STRING]}.make (an_index, a_name)))
						end
					end
					i := i + 1
				end
			end
			-- Load feature clauses from parents
			ancestor_count := et_class.ancestors.count
			from j := 1 until j > ancestor_count loop
				ancestor := universe.class_by_name (et_class.ancestors.item (j).name.name)
				if ancestor /= Void and then ancestor.feature_clauses /= Void then
					nb := ancestor.feature_clauses.count
					from i := 1 until i > nb loop
						a_feature_clause := ancestor.feature_clauses.item (i)
						a_name := feature_clause_name (a_feature_clause)
						if not Options.ignored_feature_clauses.has (a_name) then
							if not (Options.is_feature_clause_export_none_ignored and a_feature_clause.clients.has_class (universe.none_type.base_class)) then
								Options.feature_clause_order.start
								Options.feature_clause_order.search_forth (a_name)
								if Options.feature_clause_order.off then
									an_index := Options.user_defined_feature_clause_index
								else
									an_index := Options.feature_clause_order.index
								end
								feature_clauses.force_last (create {DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]}.make (a_feature_clause, create {DS_PAIR [INTEGER, STRING]}.make (an_index, a_name)))
							end
						end
						i := i + 1
					end
				end
				j := j + 1
			end

			Feature_clause_sorter.sort (feature_clauses)
		end

	feature_clause_name (a_feature_clause: ET_FEATURE_CLAUSE): STRING is
			-- Name for `a_feature_clause'.
		local
			comment: STRING
			i, j: INTEGER
		do
			create Result.make_empty
			if attached a_feature_clause.break and then attached a_feature_clause.break.text then
				comment := a_feature_clause.break.text
			else
				comment := ""
			end
			i := comment.substring_index ("--", 1)
			if i > 0 then
				j := comment.index_of ('%N', i)
				if j = 0 then
					j := comment.index_of ('%R', i)
				end
				if j > 0 then
					Result.append_string (comment.substring (i+2, j-1))
				end
			end
			STRING_.left_adjust (Result)
			STRING_.right_adjust (Result)
		end

	build_features_list is
			-- Build features list for 'et_class'.
		local
			i, nb: INTEGER
			a_feature: ET_FEATURE
		do
			create features.make (100)
			nb := et_class.queries.count
			from i := 1 until i > nb loop
				a_feature := et_class.queries.item (i)
				if not Options.ignored_inherit_classes.has (a_feature.implementation_class.name.name) or a_feature.implementation_class = et_class then
					if Options.are_classes_flat or else a_feature.implementation_class.is_equal (et_class) then
						add_feature (a_feature)
					end
				end
				i := i + 1
			end
			nb := et_class.procedures.count
			from i := 1 until i > nb loop
				a_feature := et_class.procedures.item (i)
				if not Options.ignored_inherit_classes.has (a_feature.implementation_class.name.name) or a_feature.implementation_class = et_class then
					if Options.are_classes_flat or else a_feature.implementation_class.is_equal (et_class) then
						add_feature (a_feature)
					end
				end
				i := i + 1
			end
			Feature_sorter.sort (features)
		end

	add_feature (a_feature: ET_FEATURE) is
			-- Add 'a_feature' to 'features'.
		do
			if not Options.is_inherit_export_none_ignored or else not a_feature.clients.has_class (universe.none_type.base_class) then
				features.force_last (a_feature)

				if a_feature.implementation_class.is_equal (et_class) then
					Context.global_index.force_last (create {EDOC_FEATURE_INDEX_ENTRY}.make (a_feature))
				end
			end
		end

	build_creators is
			-- Build creators list for 'et_class'.
		local
			i, j, nb_i, nb_j: INTEGER
			a_creator: ET_CREATOR
			a_clients: ET_CLIENT_LIST
			a_feature: ET_FEATURE
		do
			create creators.make
			if et_class.creators /= Void then
				nb_i := et_class.creators.count
				from i := 1 until i > nb_i loop
					a_creator := et_class.creators.item (i)
					a_clients := a_creator.clients
					nb_j := a_creator.count
					from j := 1 until j > nb_j loop
						a_feature := et_class.named_feature (a_creator.item (j).feature_name)
						if a_feature = Void then
-- TODO: what to do here? This should only happen when flatten doesn't work since errors occured while parsing
--							Error_handler.raise_warning (Error_handler.Error_creator_name_not_in_class, a_creator.item (j).feature_name.name)
						else
							Context.global_index.force_last (create {EDOC_CREATOR_INDEX_ENTRY}.make (et_class, a_feature))
							creators.force_last (create {DS_PAIR [ET_FEATURE, ET_CLIENT_LIST]}.make (a_feature, a_clients))
						end
						j := j + 1
					end
					i := i + 1
				end
			end
		end

	print_comment (a_string: STRING) is
			-- Print `a_string' as comment.
		require
			a_string_not_void: a_string /= Void
		do
			file.print_comment (a_string, et_class, features, True)
		end

	available_parents (a_class: ET_CLASS): DS_LINKED_LIST [ET_PARENT] is
			-- Parents of `a_class' which aren't exported to none or ignored by output options
		require
			a_class_not_void: a_class /= Void
		local
			i: INTEGER
			parent: ET_PARENT
			exports: ET_EXPORT_LIST
			all_export: ET_ALL_EXPORT
			parent_master_class: ET_MASTER_CLASS
		do
			create Result.make
			if a_class.parents /= Void then
				from i := 1 until i > a_class.parents.count loop
					parent := a_class.parents.item (i).parent
--					parent_master_class := universe.master_class_by_name (parent.type.name.name)
					if not Options.ignored_inherit_classes.has (parent.type.name.name) then
						exports := parent.exports
						if exports = Void or not Options.is_inherit_export_none_ignored then
							Result.force_last (parent)
						else
							if exports.is_empty then
								all_export := Void
							else
								all_export ?= exports.first
							end
							if all_export = Void or else not all_export.clients_clause.has_class (universe.none_type.base_class) then
								Result.force_last (parent)
							end
						end
					end
					i := i + 1
				end
			end
		ensure
			available_parents_not_void: Result /= Void
		end

	print_parent_list (a_class: ET_CLASS) is
			-- Print parent list of 'a_class'.
		require
			a_class_not_void: a_class /= Void
		local
			a_parents_list: DS_LIST [ET_PARENT]
			a_parent: ET_PARENT
			a_cursor: DS_LIST_CURSOR [ET_PARENT]
			a_link: STRING
			a_line: STRING
		do
			a_parents_list := available_parents (a_class)
			if not a_parents_list.is_empty then
				file.start_tag_css ("div", css_inherit_list)
				a_cursor := a_parents_list.new_cursor
				from
					a_cursor.start
				until
					a_cursor.after
				loop
					a_parent := a_cursor.item
					a_link := html_context.class_link_by_name (a_parent.type.name)
					if a_link = Void then
						a_line := file.tag_css_content_to_string ("span", css_class_name, a_parent.type.name.name)
					else
						a_line := file.link_css_content_to_string (a_link, css_linked_class_name, a_parent.type.name.name)
					end
					if a_parent.type.actual_parameters = Void then
						file.tag_content ("div", a_line)
					else
						file.start_tag ("div")
						file.content_line (a_line)
						file.indent
						a_parent.type.actual_parameters.process (Current)
						file.end_tag
					end
					if Options.is_inherit_tree_generated then
						print_parent_list (universe.master_class_by_name (a_parent.type.name.name).actual_class)
					end
					a_cursor.forth
				end
				file.end_tag
			end
		end

	print_client_list_to_string (a_class_name_list: ET_CLIENT_LIST): STRING is
			-- Print class name list to string.
		require
			a_class_name_list_not_void: a_class_name_list /= Void
		local
			i, nb: INTEGER
			a_class_name: ET_CLASS_NAME
			a_class: ET_CLASS
		do
			create Result.make_empty
			nb := a_class_name_list.count
			if nb > 0 then
				Result.append_string (file.tag_css_content_to_string ("span", css_symbol, "{"))
				from i := 1 until i > nb loop
					a_class_name := a_class_name_list.item (i).name
					a_class := universe.class_by_name (a_class_name.name)
					if a_class = Void then
						Result.append_string (file.tag_css_content_to_string ("span", css_class_name, a_class_name.name))
					else
						Result.append_string (file.print_class_name_to_string (a_class))
					end
					if i < nb then
						Result.append_string (file.tag_css_content_to_string ("span", css_symbol, ", "))
					end
					i := i + 1
				end
				Result.append_string (file.tag_css_content_to_string ("span", css_symbol, "}"))
			end
		ensure
			reusult_not_void: Result /= Void
		end

	print_feature_list is
			-- Print a list of all features of `et_class'.
		local
			a_creator_cursor: DS_LIST_CURSOR [DS_PAIR [ET_FEATURE, ET_CLIENT_LIST]]
			a_feature: ET_FEATURE
			a_clause: DS_PAIR [ET_FEATURE_CLAUSE, DS_PAIR [INTEGER, STRING]]
			a_link, last_clause: STRING
			a_clause_printed: BOOLEAN
		do
			file.start_tag_css ("div", css_feature_list)
			if not creators.is_empty then
				file.tag_attributes_content ("h2", << "id", "features-list" >>, "Creation")
				file.start_tag_css ("ul", css_feature_list_feature)
				a_creator_cursor := creators.new_cursor
				from
					a_creator_cursor.start
				until
					a_creator_cursor.after
				loop
					a_feature := a_creator_cursor.item.first
					file.tag_content ("li", file.link_css_content_to_string (html_context.creator_link_by_feature (a_feature, Void), css_linked_feature_name, html_context.xhtml_escaped_string (a_feature.name.name)))
					a_creator_cursor.forth
				end
				file.end_tag

				file.tag_content ("h2", "Features")
			else
				file.tag_attributes_content ("h2", << "id", "features-list" >>, "Features")
			end

			file.start_tag_css ("ul", css_feature_list_clause)
			from
				feature_clauses.start
			until
				feature_clauses.after
			loop
				a_clause := feature_clauses.item_for_iteration
				a_clause_printed := False
				from
					features.start
				until
					features.after
				loop
					if features.item_for_iteration.feature_clause = a_clause.first then
						if not a_clause_printed then
							a_clause_printed := True

							if last_clause = Void or else not last_clause.is_equal (a_clause.second.second) then
								if last_clause /= Void then
									file.end_tag
									file.end_tag
								end
								last_clause := a_clause.second.second
								file.start_tag ("li")
								file.tag_content ("strong", file.link_content_to_string ("#"+"clause-"+html_context.xhtml_compatible_anchor (a_clause.second.second), html_context.xhtml_escaped_string (a_clause.second.second)))
								file.start_tag_css ("ul", css_feature_list_feature)
							end

						end

						a_link := html_context.feature_link_by_feature (features.item_for_iteration, Void)
						file.tag_content ("li", file.link_css_content_to_string (a_link, css_linked_feature_name, html_context.xhtml_escaped_string (features.item_for_iteration.name.name)))
					end
					features.forth
				end
				feature_clauses.forth
			end
			if last_clause /= Void then
				file.end_tag
				file.end_tag
			end
			file.end_tag

			file.tag_content ("h2", file.link_content_to_string ("#invariant", "Invariants"))
			file.end_tag
		end

end
