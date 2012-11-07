indexing

	description:

		"Generate an HTML File for a list of all classes in the context."

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_CLASSES_FILE

inherit

	EDOC_HTML_OUTPUT_FILE

create

	make

feature -- Basic operations

	generate is
			-- Generate classes file.
		local
			a_class: ET_CLASS
			a_class_cursor: DS_LIST_CURSOR [ET_CLASS]
			a_line: STRING
		do
			open_write

			print_html_head ("Classes", html_context.relative_css_link)

			start_tag ("body")

				print_header_start
				print_buttons
				print_header_end

				tag_content ("h1", "Classes")

				tag ("hr")
				start_tag_css ("ul", css_index_list)

				a_class_cursor := Context.documented_classes.new_cursor
				from
					a_class_cursor.start
				until
					a_class_cursor.after
				loop
					a_class := a_class_cursor.item
					start_tag ("li")
					a_line := print_class_name_to_string (a_class)
					a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Class in "+print_qualified_cluster_name_to_string (a_class.group.cluster, True)))
--					a_line.append_string (print_class_description_to_string (a_class))
					content_line (a_line)
					end_tag
					a_class_cursor.forth
				end
				end_tag

				print_footer_start
				print_buttons
				print_footer_end

			end_tag
			end_tag

			close
		end

	print_class_description_to_string (a_class: ET_CLASS) : STRING
		do
			create Result.make (100)
			a_class.first_indexing.do_if (agent (an_item: ET_INDEXING_ITEM) do end (?), agent is_description (?))
		end

	is_description (an_indexing_item: ET_INDEXING_ITEM) : BOOLEAN
		do
			if attached {ET_TAGGED_INDEXING} an_indexing_item as l_ti then
				Result := l_ti.tag.identifier.name.is_case_insensitive_equal ("description")
			else
				Result := False
			end
		end

	class_description (an_indexing_item: ET_INDEXING_ITEM) : STRING
		do
			create Result.make_empty
--			if attached {ET_TAGGED_INDEXING} an_indexing_item as l_ti then
--				l_ti.terms.do_all (agent (a_item: ET_INDEXING_TERM_ITEM; a_string : STRING)
--					do
--						if a_item.indexing_term. then

--						end
--					end (?, Result))
--			end
		end

end
