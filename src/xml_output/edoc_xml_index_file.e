indexing

	description:

		"An index file"

	copyright: "Copyright (c) 2007-2010, Beat Herlig"
	license: "Eiffel Forum License v2 (see forum.txt)"
	author: "bherlig"
	date: "$Date: 2007-02-28 11:56:40 -0800 (Mit, 28 Feb 2007) $"
	revision: "$Revision: 2553 $"

class EDOC_XML_INDEX_FILE

inherit

	EDOC_XML_OUTPUT_FILE

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
				print_xml_head ("Index", xml_context.relative_xsd_link)
			else
				print_xml_head ("Index "+CHARACTER_.as_upper (letter).out, xml_context.relative_xsd_link)
			end

			print_header_start
			print_index_buttons
			print_header_end

			if letter = '%U' then
				tag_content ("title", "Index All")
			else
				tag_content ("title", "Index "+CHARACTER_.as_upper (letter).out)
			end

			start_tag ("itemizedlist")
			index_cursor := Context.global_index.new_cursor
			from
				index_cursor.start
			until
				index_cursor.after
			loop
				if letter = '%U' or CHARACTER_.as_lower (index_cursor.item.index_name.item (1)) = CHARACTER_.as_lower (letter) then
					start_tag ("listitem")
					start_tag ("para")
					index_cursor.item.process (Current)
					end_tag -- para
					end_tag -- listitem
				end
				index_cursor.forth
			end
			end_tag -- itemized list

			print_footer_start
			print_buttons
			print_index_buttons
			print_footer_end

			print_xml_footer
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
				a_line.append_string (tag_content_to_string ("cluster_description", " - Cluster in "+print_qualified_cluster_name_to_string (a_cluster.parent, True)))
			else
				a_line.append_string (tag_content_to_string ("cluster_description", " - Cluster"))
			end
			content_line (a_line)
		end

	process_class_entry (an_entry: EDOC_CLASS_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
		do
			a_line := print_class_name_to_string (an_entry.et_class)
			a_line.append_string (" - Class in ")
			a_line.append_string (print_qualified_cluster_name_to_string (an_entry.et_class.group.cluster, True))
			content_line (a_line)
		end

	process_feature_entry (an_entry: EDOC_FEATURE_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
			a_feature: ET_FEATURE
		do
			a_feature := an_entry.et_feature
			a_line := tag_attributes_content_to_string ("featurename", << "url", xml_context.feature_link_by_feature (a_feature, a_feature.implementation_class) >>, xml_context.xhtml_escaped_string (a_feature.name.name))
			a_line.append_string (" - Feature in ")
			a_line.append_string (print_qualified_class_name_to_string (a_feature.implementation_class))
			content_line (a_line)
		end

	process_creator_entry (an_entry: EDOC_CREATOR_INDEX_ENTRY) is
			-- Process `an_entry'.
		local
			a_line: STRING
			a_feature: ET_FEATURE
		do
			a_feature := an_entry.et_feature
			a_line := tag_attributes_content_to_string ("creator", << "url", xml_context.creator_link_by_feature (a_feature, an_entry.et_class) >>, xml_context.xhtml_escaped_string (a_feature.name.name))
			a_line.append_string (" - Creator in ")
			a_line.append_string (print_qualified_class_name_to_string (a_feature.implementation_class))
			content_line (a_line)
		end

feature {NONE} -- Implementation

	print_index_buttons is
			-- Print index buttons.
		local
			a_letter: CHARACTER
		do
			start_tag ("button_list")
			from a_letter := 'a' until a_letter > 'z' loop
				if a_letter = letter then
					print_button (CHARACTER_.as_upper (a_letter).out, xml_context.Active_page_link)
				else
					print_button (CHARACTER_.as_upper (a_letter).out, xml_context.relative_index_link (a_letter))
				end
				a_letter := a_letter.next
			end
			if Options.is_index_all_generated then
				if letter = '%U' then
					print_button ("All", xml_context.Active_page_link)
				else
					print_button ("All", xml_context.relative_index_all_link)
				end
			end
			end_tag -- button_list
		end

end
