indexing

	description:

		"An index file"

	copyright: "Copyright (c) 2003-2006, Julian Tschannen"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class EDOC_HTML_INDEX_FILE

inherit

	EDOC_HTML_OUTPUT_FILE

	EDOC_INDEX_PROCESSOR

	KL_IMPORTED_CHARACTER_ROUTINES
		export {NONE} all end

create

	make

feature -- Access

	letter: CHARACTER
			-- Letter of index page

feature -- Element change

	set_letter (a_letter: like letter) is
			-- Set `letter' to `a_letter'
		do
			letter := a_letter
		ensure
			letter_set: letter = a_letter
		end

feature -- Basic operations

	generate is
			-- Generate class file for `et_class'.
		local
			index_cursor: DS_LIST_CURSOR [EDOC_INDEX_ENTRY]
		do
			open_write

			if letter = '%U' then
				print_html_head ("Index", html_context.relative_css_link)
			else
				print_html_head ("Index "+CHARACTER_.as_upper (letter).out, html_context.relative_css_link)
			end

			start_tag ("body")

				print_header_start
				print_buttons
				print_index_buttons
				print_header_end

				if letter = '%U' then
					tag_content ("h1", "Index All")
				else
					tag_content ("h1", "Index "+CHARACTER_.as_upper (letter).out)
				end

				tag ("hr")
				start_tag_css ("ul", css_index_list)

				index_cursor := Context.global_index.new_cursor
				from
					index_cursor.start
				until
					index_cursor.after
				loop
					if letter = '%U' or CHARACTER_.as_lower (index_cursor.item.index_name.item (1)) = CHARACTER_.as_lower (letter) then
						start_tag ("li")
						index_cursor.item.process (Current)
						end_tag
					end
					index_cursor.forth
				end

				end_tag

				print_footer_start
				print_buttons
				print_index_buttons
				print_footer_end

			end_tag -- body
			end_tag -- html

			close
		end

feature -- Processing

	process_cluster_entry (an_entry: EDOC_CLUSTER_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
			a_cluster: ET_CLUSTER
		do
			a_cluster := an_entry.cluster
			a_line := print_cluster_name_to_string (a_cluster)
			if a_cluster.parent /= Void then
				a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Cluster in "+print_qualified_cluster_name_to_string (a_cluster.parent, True)))
			else
				a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Cluster"))
			end
			content_line (a_line)
		end

	process_class_entry (an_entry: EDOC_CLASS_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
		do
			a_line := print_class_name_to_string (an_entry.et_class)
			a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Class in "+print_qualified_cluster_name_to_string (an_entry.et_class.group.cluster, True)))
			content_line (a_line)
		end

	process_feature_entry (an_entry: EDOC_FEATURE_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
			a_feature: ET_FEATURE
		do
			a_feature := an_entry.et_feature
			a_line := link_css_content_to_string (html_context.feature_link_by_feature (a_feature, a_feature.implementation_class), css_linked_feature_name, html_context.xhtml_escaped_string (a_feature.name.name))
			a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Feature in "+print_qualified_class_name_to_string (a_feature.implementation_class)))
			content_line (a_line)
		end

	process_creator_entry (an_entry: EDOC_CREATOR_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
			a_feature: ET_FEATURE
		do
			a_feature := an_entry.et_feature
			a_line := link_css_content_to_string (html_context.creator_link_by_feature (a_feature, an_entry.et_class), css_linked_feature_name, html_context.xhtml_escaped_string (a_feature.name.name))
			a_line.append_string (tag_css_content_to_string ("span", css_index_small, " - Creator in "+print_qualified_class_name_to_string (an_entry.et_class)))
			content_line (a_line)
		end

feature {NONE} -- Implementation

	print_index_buttons is
			-- Print index buttons.
		local
			a_letter: CHARACTER
		do
			start_tag_css ("div", css_buttons)
			from a_letter := 'a' until a_letter > 'z' loop
				if a_letter = letter then
					print_button (CHARACTER_.as_upper (a_letter).out, html_context.Active_page_link)
				else
					print_button (CHARACTER_.as_upper (a_letter).out, html_context.relative_index_link (a_letter))
				end
				a_letter := a_letter.next
			end
			if Options.is_index_all_generated then
				if letter = '%U' then
					print_button ("All", html_context.Active_page_link)
				else
					print_button ("All", html_context.relative_index_all_link)
				end
			end
			end_tag
		end

end
